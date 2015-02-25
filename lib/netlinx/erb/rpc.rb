# -----------------------------------------------------------------------------
# The MIT License (MIT)

# Copyright (c) 2014 Alex McLain and Joe McIlvain

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# -----------------------------------------------------------------------------

require 'netlinx/workspace'

# :nodoc:
class RPC
  
  # :nodoc:
  def self.build
    fn_exp = /
    (?#
      Pull out comment\\description above the function, enclosed in slash\\star syntax.
      Does not have to exist.
    )
    ^(?<desc>[\t ]*\/\*(?:[^\*]|\*[^\/])*\*\/)?\s*

    (?# Find the function definition. )
    define_function\s+

    (?# Capture function's return type, if it exists.)
    (?<rtn>\w+(?<width>\[\d+\])?)??\s*

    (?# Capture the function name. )
    (?<name>\w+)

    (?#
      Capture the function parameters.
      Run this through another regex to get the type\\name pairs.
    )
    \(\s*(?<params>.*?)\s*\)\s*

    (?# Capture the function's source code. )
    {[\r\n]*(?<code>(?:.|\r|\n)*?)?[\r\n]*}
    /x

    param_exp = /\s*(?:(?<type>\w+)\s+(?<name>\w+(?<width>\[\d*\])?)),?\s*/

    sections = {} # Collect a set of matches for each file, separated by file.


    # Pull file list from workspace.
    workspace = NetLinx::Workspace.search
    raise Errno::ENOENT, 'Workspace not found.' unless workspace

    file_paths = workspace.projects.first.systems.first.files
      .map(&:path)
      .select { |path| path =~ /(\.axi|\.axs)$/ }
      .reject { |path| path =~ /rpc(?:-|_.*?)?\.axi/ } # Remove RPC files.

    # file_paths = Dir['**/*.axi']

    file_paths.each do |f|
      str = File.open(f.gsub('\\', '/'), "r:iso-8859-1").read
      matches = []
      
      while str =~ fn_exp
        matches << $~
        str = $'
      end
      
      sections[f] = matches
    end

    # -----------------------
    # Documentation Generator
    # -----------------------

    # output = ''
    # sections.each do |name, matches|
      
    #   output << "--------------------------------------------------\n"
    #   output << "FILE: '#{name}'\n"
    #   output << "--------------------------------------------------\n"
    #   output << "\n\n"
      
    #   matches.each do |m|
    #     output << m[:desc].to_s
    #     output << "\n"
    #     output << m[:name].to_s
    #     output << "\n\n\n"
    #   end
      
    # end

    # File.open('functions.axi', 'w+') { |f| f << output }


    # ----------------------
    # RPC Function Generator
    # ----------------------

    # Generate list of included and excluded files for sanity check.
    directory_files = Dir['**/*.axi'] + Dir['**/*.axs']

    included_files  = ''
    file_paths.each { |path| included_files << path.to_s.gsub('\\', '/') + "\n" } # TODO: As string.

    excluded_files  = ''
    (directory_files - file_paths.map { |path| path.gsub '\\', '/' }).each { |path| excluded_files << path.to_s.gsub('\\', '/') + "\n" }

    fn_symbols = [] # Symbol names to avoid duplicates.
    output = ''

    output << <<-EOS
(***********************************************************)
(*                         WARNING                         *)
(***********************************************************)
(*  This file is automatically generated.                  *)
(***********************************************************)

/*
Included Files:
---------------
#{included_files}

Excluded Files:
---------------
#{excluded_files}
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
        
EOS

    sections.each do |name, matches|
      output << "        /*------------------------------------------------------------------/\n"
      output << "            FILE: '#{name}'\n"
      output << "        /------------------------------------------------------------------*/\n\n"
      
      
      matches.each do |fn|
        function_valid = true
        fn_output      = ''
        return_type    = fn[:rtn].nil? ? nil : fn[:rtn].downcase.to_sym
        # TODO: Calculate return value width.
        params         = []
        
        # Store function name as symbol and check for duplicates.
        fn_sym = fn[:name].downcase.to_sym
        
        if fn_symbols.include? fn_sym
          output << "        // Already defined.\n"
          function_valid = false
        else
          fn_symbols << fn_sym
        end
        
        # Retrieve params.
        str = fn[:params]
        while str =~ param_exp
          params << $~
          str = $'
        end
        
        # Generate function handler.
        fn_output << "        if(compare_string(f_name, '#{fn[:name].downcase}'))\n"
        fn_output << "        {\n"
        
        # Generate return value.
        if return_type
          case return_type
          when :integer
            fn_output << "            #{return_type.to_s} return_value;\n"
          end
          
          fn_output << "            \n"
        end
        
        fn_output << "            print(LOG_LEVEL_INFO, 'RPC: #{fn[:name]}()');\n"
        fn_output << "            \n"
        
        # Set return value equal to function if return value exists.
        fn_output << "            "
        fn_output << "return_value = " if return_type
        
        fn_output << "#{fn[:name]}("
        fn_output << ");\n" if params.empty?

        function_valid = false unless [nil, :integer].include? return_type
          
        # Generate parameters.
        param_index = 0
        params.each do |param|
          param_index += 1
          
          valid_params = [:integer]
          type = param[:type].downcase.to_sym
          
          unless valid_params.include? type
            function_valid = false
            break
          end
          
          case type
          when :integer
            fn_output << "\n                rpc_get_arg_i(#{param_index}, data.text),"
          end
        end
        
        # Remove trailing comma from last arg.
        fn_output.chop! unless params.empty?
        
        # Close function.
        fn_output << "\n            );\n" unless params.empty?
        
        # Print return value if exists.
        if return_type
          fn_output << "            \n"
          
          case return_type
          when :integer
            fn_output << "            print(LOG_LEVEL_INFO, \"'RPC RTN: ', itoa(return_value)\");\n"
          end
        end
        
        fn_output << "        }\n\n"

        # Store function string.
        if function_valid
          output << fn_output 
        else
          output << "        // Skipped:\n"
          output << "        // #{fn[:name]}(#{fn[:params]})\n\n"
        end
      end
      
    end

    output << "    }\n"
    output << "}\n"
    output << "#end_if\n\n"


    File.open('include/rpc-functions.axi', 'w+') { |f| f << output }
  end
  
end