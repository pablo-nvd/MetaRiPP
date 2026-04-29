
  SET(ENV{PYTHONPATH} /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/scripts/python:/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/build/lib)
  SET(ENV{LD_LIBRARY_PATH} /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/scripts/python:/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/build/lib:$ENV{LD_LIBRARY_PATH})
  SET(ENV{BABEL_LIBDIR} /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/build/lib)
  SET(ENV{BABEL_DATADIR} /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/data)
  MESSAGE("/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/scripts/python:/home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/build/lib")
  EXECUTE_PROCESS(
  	COMMAND /usr/bin/python3.10 /home/pvillanueva/RiPPMiner/rippminer_standalone/downloads/openbabel-2.3.2/test/testbabel.py 
  	#WORKING_DIRECTORY 
  	RESULT_VARIABLE import_res
  	OUTPUT_VARIABLE import_output
  	ERROR_VARIABLE  import_output
  )
  
  # Pass the output back to ctest
  IF(import_output)
    MESSAGE(${import_output})
  ENDIF(import_output)
  IF(import_res)
    MESSAGE(SEND_ERROR ${import_res})
  ENDIF(import_res)
