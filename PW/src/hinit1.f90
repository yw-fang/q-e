!
! Copyright (C) 2001-2011 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!----------------------------------------------------------------------------
SUBROUTINE hinit1()
  !----------------------------------------------------------------------------
  !! Atomic configuration dependent hamiltonian initialization,
  !! potential, wavefunctions for Hubbard U.  
  !! Important note: it does not recompute structure factors and core charge,
  !! they must be computed before this routine is called.
  !
  USE kinds,               ONLY : DP
  USE ions_base,           ONLY : nat, nsp, ityp, tau
  USE cell_base,           ONLY : alat, at, bg, omega, tpiba2
  USE fft_base,            ONLY : dfftp
  USE gvecs,               ONLY : doublegrid
  USE ldaU,                ONLY : lda_plus_u
  USE lsda_mod,            ONLY : nspin
  USE noncollin_module,    ONLY : report
  USE scf,                 ONLY : vrs, vltot, v, kedtau
  USE control_flags,       ONLY : tqr, use_gpu
  USE realus,              ONLY : generate_qpointlist, betapointlist, &
                                  init_realspace_vars, real_space
  USE wannier_new,         ONLY : use_wannier
  USE martyna_tuckerman,   ONLY : tag_wg_corr_as_obsolete
  USE scf,                 ONLY : rho
  USE paw_variables,       ONLY : okpaw, ddd_paw
  USE paw_onecenter,       ONLY : paw_potential
  USE paw_symmetry,        ONLY : paw_symmetrize_ddd
  USE dfunct,              ONLY : newd
  USE exx_base,            ONLY : coulomb_fac, coulomb_done
  !
  USE scf_gpum,            ONLY : using_vrs
  USE ener,                ONLY : esol, vsol
  USE rism_module,         ONLY : lrism, rism_update_pos, rism_calc3d
  !
#if defined (__ENVIRON)
  USE plugin_flags,        ONLY : use_environ
  USE environ_base_module, ONLY : update_environ_ions, update_environ_cell
  USE environ_pw_module,   ONLY : calc_environ_potential
#endif
  !
  IMPLICIT NONE
#if defined (__ENVIRON)
  REAL(DP) :: at_scaled(3, 3)
  REAL(DP) :: tau_scaled(3, nat)
#endif
  !
  ! ... update solute position for 3D-RISM
  !
  IF (lrism) CALL rism_update_pos()
  !
  ! these routines can be used to patch quantities that are dependent
  ! on the ions and cell parameters
  !
#if defined (__ENVIRON)
  IF (use_environ) THEN
     at_scaled = at * alat
     tau_scaled = tau * alat
     CALL update_environ_ions(tau_scaled)
     CALL update_environ_cell(at_scaled)
  END IF
#endif
  !
  ! ... calculate the total local potential
  !
  CALL setlocal()
  !
  ! ... more position-dependent initializations
  !
  IF ( tqr ) CALL generate_qpointlist()
  !
  IF ( real_space ) THEN
     CALL betapointlist()
     CALL init_realspace_vars()
  ENDIF
  !
  IF ( report /= 0 ) CALL make_pointlists( )
  !
  CALL tag_wg_corr_as_obsolete
  !
  ! ... calculate 3D-RISM to get the solvation potential
  !
  IF (lrism) CALL rism_calc3d(rho%of_g(:, 1), esol, vsol, v%of_r, -1.0_DP)
  !
  ! ... plugin contribution to local potential
  !
#if defined (__ENVIRON)
  IF (use_environ) CALL calc_environ_potential(rho, .FALSE., -1.D0, vltot)
#endif
  !
  ! ... define the total local potential (external+scf)
  !
  CALL using_vrs(1)
  CALL set_vrs( vrs, vltot, v%of_r, kedtau, v%kin_r, dfftp%nnr, nspin, &
                doublegrid )
  !
  ! ... update the D matrix and the PAW coefficients
  !
  IF ( okpaw ) THEN
     CALL compute_becsum( 1 )
     CALL PAW_potential( rho%bec, ddd_paw )
     CALL PAW_symmetrize_ddd( ddd_paw )
  ENDIF
  ! 
  CALL newd()
  !
  ! ... and recalculate the products of the S with the atomic wfcs used 
  ! ... in DFT+Hubbard calculations
  !
  IF (.NOT. use_gpu) THEN
    IF ( lda_plus_u  ) CALL orthoUwfc(.FALSE.)
    IF ( use_wannier ) CALL orthoatwfc( .TRUE. )
  ELSE
    IF ( lda_plus_u  ) CALL orthoUwfc_gpu() 
    IF ( use_wannier ) CALL orthoatwfc_gpu( .TRUE. )
  ENDIF
  !
  ! ... The following line forces recalculation of terms used by EXX
  ! ... It is actually needed only in case of variable-cell calculations
  ! FIXME: array coulomb_fac may take a large amount of memory: worth it? 
  !
  IF ( ALLOCATED(coulomb_fac) ) DEALLOCATE (coulomb_fac, coulomb_done)
  !
  RETURN
  !
END SUBROUTINE hinit1
