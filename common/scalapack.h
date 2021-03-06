#pragma once
#include "index.h"
#include "import.h"

#ifdef _WIN32
#define pdlaset_ PDLASET
#define pdelset_ PDELSET
#define pdlange_ PDLANGE
#define pdgesv_ PDGESV
#define pdgetrf_ PDGETRF
#define pdpotrf_ PDPOTRF
#define pdgemm_ PDGEMM
#define pdgesvd_ PDGESVD
#endif

#ifdef __cplusplus
extern "C"
{
#endif
    void pdelset_(double*, blas_idx_t&, blas_idx_t&, blas_idx_t*, double&);

    void pdlaset_ (char&, 
        blas_idx_t&, blas_idx_t&,  
        double&,  double&,  
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*);
        
    double pdlange_ (char&, 
        blas_idx_t&, blas_idx_t&, 
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*,
        double*);

    void pdgemm_ (char &, char &, 
        blas_idx_t &, blas_idx_t &, blas_idx_t &, 
        double &, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *, 
        double &, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *);

    void pdgesv_ (blas_idx_t &, blas_idx_t &, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *, 
        blas_idx_t *, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *, blas_idx_t &);

    void pdgetrf_ (blas_idx_t &, blas_idx_t &, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *,
        blas_idx_t *, 
        blas_idx_t &);

    void pdgetrs_(char&, 
        blas_idx_t&, blas_idx_t&, 
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*, 
        blas_idx_t*, 
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*, 
        blas_idx_t&);

    void pdgetri_(blas_idx_t&, 
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*, 
        blas_idx_t*, 
        double*, blas_idx_t&, 
        blas_idx_t*, blas_idx_t&, 
        blas_idx_t&);

    void pdpotrf_ (char &, blas_idx_t &, 
        double *, blas_idx_t &, blas_idx_t &, blas_idx_t *, blas_idx_t &);

    void pdgehrd_ (blas_idx_t &,blas_idx_t &,blas_idx_t&, 
        double *, blas_idx_t&, blas_idx_t&, blas_idx_t*, 
        double *, double *, blas_idx_t&, blas_idx_t&);

    void pdlahqr_ (blas_idx_t &, blas_idx_t &,  blas_idx_t &, 
        blas_idx_t &, blas_idx_t &,  double*, blas_idx_t *, 
        double*, double*, blas_idx_t &, blas_idx_t &, 
        double*, blas_idx_t *, double*, blas_idx_t &, 
        blas_idx_t *, blas_idx_t &, blas_idx_t &);

    // SUBROUTINE PDGESVD(JOBU,JOBVT,M,N,A,IA,JA,DESCA,S,U,IU,JU,DESCU, VT,IVT,JVT,DESCVT,WORK,LWORK,INFO)
    void pdgesvd_ (char&, char&, blas_idx_t&, blas_idx_t&, 
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*,
        double*,
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*,
        double*, blas_idx_t&, blas_idx_t&, blas_idx_t*,
        double*, blas_idx_t&, blas_idx_t&);

#ifdef __cplusplus
};
#endif
