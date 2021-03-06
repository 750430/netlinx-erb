(***********************************************************)
(*                         WARNING                         *)
(***********************************************************)
(*  This file is automatically generated.                  *)
(***********************************************************)

/*
Included Files:
---------------
My Project.axs
include/cable-box.axi
include/rpc-functions.axi
include/ui/panel-conference-table.axi
include/ui/panel-wall.axi
include/ui/_config.axi


Excluded Files:
---------------
include/rpc.axi

*/


#if_not_defined RPC_FUNCTION_LIST
#define RPC_FUNCTION_LIST 1

DEFINE_EVENT

data_event[vdvRPC]
{
    string:
    {
        char f_name[255];
        f_name = rpc_function_name(data.text);
        
        /*------------------------------------------------------------------/
            FILE: 'My Project.axs'
        /------------------------------------------------------------------*/

        /*------------------------------------------------------------------/
            FILE: 'include/cable-box.axi'
        /------------------------------------------------------------------*/

        if(compare_string(f_name, 'cable_box_key'))
        {
            print(LOG_LEVEL_INFO, 'RPC: cable_box_key()');
            
            cable_box_key(
                rpc_get_arg_i(1, data.text)
            );
        }

        /*------------------------------------------------------------------/
            FILE: 'include/rpc-functions.axi'
        /------------------------------------------------------------------*/

        /*------------------------------------------------------------------/
            FILE: 'include/ui/panel-conference-table.axi'
        /------------------------------------------------------------------*/

        /*------------------------------------------------------------------/
            FILE: 'include/ui/panel-wall.axi'
        /------------------------------------------------------------------*/

        /*------------------------------------------------------------------/
            FILE: 'include/ui/_config.axi'
        /------------------------------------------------------------------*/

    }
}
#end_if

