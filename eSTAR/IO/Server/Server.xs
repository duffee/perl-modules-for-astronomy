#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "string.h"
#include "globus_common.h"
#include "globus_io.h"
#include "estar_io.h"

/* memory for callback */
static SV * sv_callback;

/* static server context */
static eSTAR_IO_Server_Context_T context;

/* callback for sever */
void c_callback(globus_io_handle_t *connection_handle)
{
   dSP;
   int status;
   SV * svhandle;

   printf("connection_callbackXS ENTER\n");

   ENTER;
   SAVETMPS;
   PUSHMARK(SP);

   printf("connection_callbackXS globus_io_handle_tPtr %p\n", svhandle);
   
   svhandle = sv_newmortal();
   sv_setref_pv(svhandle, "globus_io_handle_tPtr", (void*)connection_handle);

   XPUSHs(sv_2mortal( svhandle ));
   PUTBACK;
    
   printf("connection_callbackXS\n");
   status = call_sv( sv_callback, G_SCALAR );
   printf("connection_callbackXS status = %i\n", status);

   SPAGAIN;
   FREETMPS;
   LEAVE;
    
   return;
}

MODULE = eSTAR::IO::Server  PACKAGE = eSTAR::IO::Server	

eSTAR_IO_Server_Context_T *
start_server( port, callback )
   int port
   SV * callback
  PREINIT:
    int status;
    unsigned short sport;
  CODE:
    sv_callback = callback;
    printf("start_serverXS storing callback %p\n", sv_callback);
    sport = (unsigned short) port;
    printf("start_serverXS context %p\n", &context);
    status = eSTAR_IO_Start_Mono_Server( &sport, c_callback, &context );
    RETVAL = &context;  
    printf("start_serverXS context %p\n", &context);
  OUTPUT:
    RETVAL 
  CLEANUP:
    if (status == GLOBUS_FALSE ) 
      XSRETURN_UNDEF;   
      
int 
stop_server( context )
    eSTAR_IO_Server_Context_T * context
  CODE:
    printf("close_serverXS context %p\n", &context);
    RETVAL = eSTAR_IO_Close_Server( context );
  OUTPUT:
    RETVAL  
