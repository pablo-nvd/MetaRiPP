# Install script for directory: /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "RelWithDebInfo")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/inchi" TYPE FILE FILES "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/inchi_api.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/openbabel-2.0/openbabel" TYPE FILE FILES "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/chemdrawcdx.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/openbabel-2.0/openbabel" TYPE FILE FILES
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/alias.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/atom.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/atomclass.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/base.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/bitvec.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/bond.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/bondtyper.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/builder.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/canon.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/chains.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/chargemodel.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/chiral.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/conformersearch.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/data.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/descriptor.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/dlhandler.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/fingerprint.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/forcefield.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/format.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/generic.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/graphsym.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/grid.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/griddata.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/groupcontrib.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/inchiformat.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/internalcoord.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/isomorphism.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/kinetics.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/lineend.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/locale.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/matrix.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/mcdlutil.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/mol.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/molchrg.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/obconversion.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/oberror.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/obiter.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/obmolecformat.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/obutil.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/op.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/optransform.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/parsmart.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/patty.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/phmodel.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/plugin.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/pointgroup.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/query.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/rand.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/reaction.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/residue.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/ring.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/rotamer.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/rotor.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/shared_ptr.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/spectrophore.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/text.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/tokenst.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/typer.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/xml.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/openbabel-2.0/openbabel/math" TYPE FILE FILES
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/align.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/erf.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/matrix3x3.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/spacegroup.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/transform3d.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/math/vector3.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/openbabel-2.0/openbabel/stereo" TYPE FILE FILES
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/bindings.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/cistrans.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/squareplanar.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/stereo.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/tetrahedral.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/tetranonplanar.h"
    "/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/include/openbabel/stereo/tetraplanar.h"
    )
endif()

