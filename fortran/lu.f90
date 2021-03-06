#define GAUSSIAN_A 1

program lu
    USE DISPMODULE
    implicit none
    external blacs_exit
    external blacs_gridexit
    external blacs_gridinfo
    external blacs_barrier
    external descinit
    external sl_init
    ! external pdpotrf 
    external pdgetrf 
    external dlarnv
    external pdgeadd 
    integer, external :: indxg2p
    integer, external :: numroc
    double precision, external :: MPI_Wtime 
    integer, parameter :: descriptor_len = 9
    double precision, parameter :: one = 1.0
    integer :: M 
    integer :: block_size 
    double precision :: lambda 
    integer :: processor_rows
    integer :: processor_cols 
    integer :: context
    integer :: my_row
    integer :: my_col
    integer :: local_M
    integer :: local_N
    integer :: iarow
    integer :: iacol
    ! integer :: mp0
    ! integer :: nq0
    ! integer :: work_size
    integer :: leading_dim
    integer :: info
    integer :: descriptor_A(descriptor_len)
    integer :: descriptor_A_copy(descriptor_len)
    integer :: seed(4) = [0, 0, 0, 0]
    integer :: i
    double precision :: start_time
    double precision :: end_time
    double precision, allocatable :: temp_arr(:)
    double precision, allocatable :: work(:)
    double precision, allocatable :: A(:, :)
    double precision, allocatable :: ipiv(:)
    double precision, allocatable :: A_copy(:, :)
    double precision :: gflops

    open(unit=1, file="out_lu.txt")
    open(unit=2, file="in.txt")
    read (2, *) M, block_size, lambda, processor_rows, processor_cols
    ! Initialize the process grid.
    call sl_init(processor_rows, processor_cols, context)
    call blacs_gridinfo(context, processor_rows, processor_cols, my_row, my_col)

    ! Initialize the random number seed.
    seed(1) = mod(my_row, 4096)
    seed(2) = mod(my_col, 4096)
    seed(4) = 1

    ! Check if this process is on the process grid.
    if (my_row == -1) then
        go to 10
    end if

    if (my_row == 0 .and. my_col == 0) then
        write (1, *)"Num rows", M
        write (1, *)"Block size", block_size
        write (1, *)"lambda", lambda
        write (1, *)"processor rows", processor_rows
        write (1, *)"processor cols", processor_cols
    end if

    ! Compute matrix shapes.
    local_M = numroc(M, block_size, my_row, 0, processor_rows)
    local_N = numroc(M, block_size, my_col, 0, processor_cols)
    leading_dim = max(1, local_M)

    ! Compute size of work.
    iarow = indxg2p(1, block_size, my_row, 0, processor_rows)
    iacol = indxg2p(1, block_size, my_col, 0, processor_cols)
    ! mp0 = numroc(M, block_size, my_row, iarow, processor_rows)
    ! nq0 = numroc(M, block_size, my_col, iacol, processor_cols)
    ! work_size = block_size * (mp0 + nq0 + block_size)

    ! Allocate local matrices.
    allocate(A(1:local_M, 1:local_N))
    allocate(ipiv(1:local_N+block_size))
    ! allocate(work(1:work_size))
#if GAUSSIAN_A
    allocate(A_copy(1:local_M, 1:local_N))
#endif

    ! Initialize global matrix descriptors.
    call descinit(descriptor_A, M, M, block_size, block_size, 0, 0, context, leading_dim, info)
    if (info /= 0) then
        write (1, *) "Descinit A failed argument", info, "is illegal."
        go to 10
    end if

    call descinit(descriptor_A_copy, M, M, block_size, block_size, 0, 0, context, leading_dim, info)
    if (info /= 0) then
        write(1, *) "Descinit A_copy failed argument", info, "is illegal."
        go to 10
    end if

    ! Set A = lambda I.
    if (my_row == 0 .and. my_col == 0) then
        print *, "Initializing A."
    endif
    call pdlaset("", M, M, 0.0, lambda, A, 1, 1, descriptor_A)
    print *, "SUCCES"

#if GAUSSIAN_A
    if (my_row == 0 .and. my_col == 0) then
        print *, "Adding noise to A."
    endif
    ! Add gaussian noise to all entries of A.
    allocate(temp_arr(1:local_N))
    do i = 1, local_M
        call dlarnv(3, seed, local_N, temp_arr) 
        A(i, :) = A(i, :) + temp_arr
    end do
    A_copy = A

    ! Set A = (A + A^t).
    call pdgeadd("T", M, M, one, A_copy, 1, 1, descriptor_A_copy, one, A, 1, 1, descriptor_A)
#endif


    ! Perform the LU.
    if (my_row == 0 .and. my_col == 0) then
        print *, "Running LU."
    endif
    start_time = MPI_Wtime()
    if (my_row == 0 .and. my_col == 0) then
        ! print*,A(1:10,1:6)
        CALL DISP(A(1:20,1:12), STYLE='NUMBER')
    endif

    call pdgetrf(M, M, A, 1, 1, descriptor_A,ipiv, info)
    call blacs_barrier(context, "A")
    end_time = MPI_Wtime()
    if (info /= 0) then
        write(1, *) "LU failed with error code:", info
        go to 10
    end if

    if (my_row == 0 .and. my_col == 0) then
        write(1, *) "LU took", end_time - start_time, "seconds."
        call gemm_flops(M,gflops)
        write(1, *) "perf:",gflops/(end_time - start_time),"GFlops/s"
        CALL DISP(A(1:20,1:12), STYLE='NUMBER')
        
    end if

    10 continue
    call blacs_exit(0)
end program lu

subroutine sl_init(processor_rows, processor_cols, context)
    external blacs_get
    external blacs_gridinit
    external blacs_setup
    integer, intent(in) :: processor_cols
    integer, intent(in) :: processor_rows
    integer, intent(out) :: context
    integer my_id, num_procs

    call blacs_pinfo(my_id, num_procs)
    call blacs_get(-1, 0, context)
    call blacs_gridinit(context, 'Row-major', processor_rows, processor_cols)
    return
end subroutine sl_init

subroutine gemm_flops(M,gflops)
    integer,intent(in) :: M
    double precision,intent(out):: gflops

    gflops = (2.0/3.0 * M * M * M - 1.0/2.0 * M * M)/1024.0 / 1024.0 / 1024.0
 

end subroutine gemm_flops