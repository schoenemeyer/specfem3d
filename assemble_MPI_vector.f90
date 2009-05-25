!=====================================================================
!
!               S p e c f e m 3 D  V e r s i o n  1 . 4
!               ---------------------------------------
!
!                 Dimitri Komatitsch and Jeroen Tromp
!    Seismological Laboratory - California Institute of Technology
!         (c) California Institute of Technology September 2006
!
! This program is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 2 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along
! with this program; if not, write to the Free Software Foundation, Inc.,
! 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
!
!=====================================================================

!----
!---- assemble the contributions between slices using non-blocking MPI
!----

  subroutine assemble_MPI_vector_ext_mesh(NPROC,NGLOB_AB,array_val, &
            buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh, &
            ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
            nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh,my_neighbours_ext_mesh, &
            request_send_vector_ext_mesh,request_recv_vector_ext_mesh)

  implicit none

  include "constants.h"

! include values created by the mesher
  include "OUTPUT_FILES/values_from_mesher.h"

! array to assemble
  real(kind=CUSTOM_REAL), dimension(NDIM,NGLOB_AB) :: array_val

  integer :: NPROC
  integer :: NGLOB_AB

  real(kind=CUSTOM_REAL), dimension(NDIM,max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: &
       buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh

  integer :: ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: nibool_interfaces_ext_mesh,my_neighbours_ext_mesh
  integer, dimension(max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: ibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: request_send_vector_ext_mesh,request_recv_vector_ext_mesh

  integer ipoin,iinterface

! $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

! here we have to assemble all the contributions between partitions using MPI

! assemble only if more than one partition
  if(NPROC > 1) then

! partition border copy into the buffer
  do iinterface = 1, ninterfaces_ext_mesh
    do ipoin = 1, nibool_interfaces_ext_mesh(iinterface)
      buffer_send_vector_ext_mesh(:,ipoin,iinterface) = array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface))
    enddo
  enddo

! send messages
  do iinterface = 1, ninterfaces_ext_mesh
    call issend_cr(buffer_send_vector_ext_mesh(1,1,iinterface), &
         NDIM*nibool_interfaces_ext_mesh(iinterface), &
         my_neighbours_ext_mesh(iinterface), &
         itag, &
         request_send_vector_ext_mesh(iinterface) &
         )
    call irecv_cr(buffer_recv_vector_ext_mesh(1,1,iinterface), &
         NDIM*nibool_interfaces_ext_mesh(iinterface), &
         my_neighbours_ext_mesh(iinterface), &
         itag, &
         request_recv_vector_ext_mesh(iinterface) &
         )
  enddo

! wait for communications completion (recv)
  do iinterface = 1, ninterfaces_ext_mesh
    call wait_req(request_recv_vector_ext_mesh(iinterface))
  enddo

! adding contributions of neighbours
  do iinterface = 1, ninterfaces_ext_mesh
    do ipoin = 1, nibool_interfaces_ext_mesh(iinterface)
      array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface)) = &
           array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface)) + buffer_recv_vector_ext_mesh(:,ipoin,iinterface)
    enddo
  enddo

! wait for communications completion (send)
  do iinterface = 1, ninterfaces_ext_mesh
    call wait_req(request_send_vector_ext_mesh(iinterface))
  enddo

  endif

  end subroutine assemble_MPI_vector_ext_mesh

  subroutine assemble_MPI_vector_ext_mesh_s(NPROC,NGLOB_AB,array_val, &
            buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh, &
            ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
            nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh,my_neighbours_ext_mesh, &
            request_send_vector_ext_mesh,request_recv_vector_ext_mesh &
            )

  implicit none

  include "constants.h"

! include values created by the mesher
  include "OUTPUT_FILES/values_from_mesher.h"

! array to assemble
  real(kind=CUSTOM_REAL), dimension(NDIM,NGLOB_AB) :: array_val

  integer :: NPROC
  integer :: NGLOB_AB

  real(kind=CUSTOM_REAL), dimension(NDIM,max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: &
       buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh

  integer :: ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: nibool_interfaces_ext_mesh,my_neighbours_ext_mesh
  integer, dimension(max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: ibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: request_send_vector_ext_mesh,request_recv_vector_ext_mesh

  integer ipoin,iinterface

! $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

! here we have to assemble all the contributions between partitions using MPI

! assemble only if more than one partition
  if(NPROC > 1) then

! partition border copy into the buffer
  do iinterface = 1, ninterfaces_ext_mesh
    do ipoin = 1, nibool_interfaces_ext_mesh(iinterface)
      buffer_send_vector_ext_mesh(:,ipoin,iinterface) = array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface))
    enddo
  enddo

! send messages
  do iinterface = 1, ninterfaces_ext_mesh
    call issend_cr(buffer_send_vector_ext_mesh(1,1,iinterface), &
         NDIM*nibool_interfaces_ext_mesh(iinterface), &
         my_neighbours_ext_mesh(iinterface), &
         itag, &
         request_send_vector_ext_mesh(iinterface) &
         )
    call irecv_cr(buffer_recv_vector_ext_mesh(1,1,iinterface), &
         NDIM*nibool_interfaces_ext_mesh(iinterface), &
         my_neighbours_ext_mesh(iinterface), &
         itag, &
         request_recv_vector_ext_mesh(iinterface) &
         )
  enddo

  endif

  end subroutine assemble_MPI_vector_ext_mesh_s


  subroutine assemble_MPI_vector_ext_mesh_w(NPROC,NGLOB_AB,array_val, &
            buffer_recv_vector_ext_mesh,ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
            nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh, &
            request_send_vector_ext_mesh,request_recv_vector_ext_mesh)

  implicit none

  include "constants.h"

! include values created by the mesher
  include "OUTPUT_FILES/values_from_mesher.h"

! array to assemble
  real(kind=CUSTOM_REAL), dimension(NDIM,NGLOB_AB) :: array_val

  integer :: NPROC
  integer :: NGLOB_AB

  real(kind=CUSTOM_REAL), dimension(NDIM,max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: &
       buffer_recv_vector_ext_mesh

  integer :: ninterfaces_ext_mesh,max_nibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: nibool_interfaces_ext_mesh
  integer, dimension(max_nibool_interfaces_ext_mesh,ninterfaces_ext_mesh) :: ibool_interfaces_ext_mesh
  integer, dimension(ninterfaces_ext_mesh) :: request_send_vector_ext_mesh,request_recv_vector_ext_mesh

  integer ipoin,iinterface

! $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

! here we have to assemble all the contributions between partitions using MPI

! assemble only if more than one partition
  if(NPROC > 1) then

! wait for communications completion (recv)
  do iinterface = 1, ninterfaces_ext_mesh
    call wait_req(request_recv_vector_ext_mesh(iinterface))
  enddo

! adding contributions of neighbours
  do iinterface = 1, ninterfaces_ext_mesh
    do ipoin = 1, nibool_interfaces_ext_mesh(iinterface)
      array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface)) = &
           array_val(:,ibool_interfaces_ext_mesh(ipoin,iinterface)) + buffer_recv_vector_ext_mesh(:,ipoin,iinterface)
    enddo
  enddo

! wait for communications completion (send)
  do iinterface = 1, ninterfaces_ext_mesh
    call wait_req(request_send_vector_ext_mesh(iinterface))
  enddo

  endif

  end subroutine assemble_MPI_vector_ext_mesh_w
