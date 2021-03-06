
module NetLinx
  module ERB
    
    # @return a binding for ERB to evaluate code in.
    # @yieldparam [Module] module the object whose binding is returned.
    # @example
    #   ERB.new(buffer, nil, '%<>-').result(NetLinx::ERB.binding)
    def self.binding &block
      Module.new.tap { |mod|
        mod.instance_eval { extend NetLinx::ERB::Helpers }
        block.call mod if block_given?
      }.instance_eval { binding }
    end
    
    # Run ERB on the given template file.
    # @param template_file [String] file path
    # @param binding [Binding]
    # @return [String] ERB output.
    # @raise [LoadError] template not found
    def self.execute template_file, binding: NetLinx::ERB.binding
      raise LoadError, "Template not found: #{template_file}" unless File.exists? template_file
      $AUTOGEN_HEADER + ::ERB.new(File.read(template_file), nil, '%<>-')
        .result(binding)
    end
    
    # Generate AXI files for multiple devices based on a template file.
    # @param devices [Hash] device names, each with a corresponding hash of
    #   k/v pairs that will be turned into `@tmpl_(key)` for use in the template.
    # @option kwargs [String] :template_dir ('./include/ui/template') directory
    #   containing `.axi.erb.tmpl` template files.
    # @yieldparam [Module] module the object whose binding is used when evaluating
    #   the template. This can be used to add customized data during evaluation.
    # 
    # @example
    #   # Sample input for `devices` parameter:
    #   touch_panels = {
    #       WALL:     { dps: 10001 },
    #       FLOATING: { dps: 10002 },
    #   }
    def self.generate_axi_files_from_template devices, **kwargs, &block
      template_dir = File.expand_path kwargs.fetch(:template_dir, './include/ui/template')
      template_files = Dir["#{template_dir}/*.axi.erb.tmpl"]
      
      devices.each do |name, params|
        b = self.binding do |m|
          m.instance_eval {
            extend NetLinx::ERB::Helpers
            
            # Generate template instance variables.
            @tmpl_suffix       = name.to_s
            @tmpl_var_suffix   = name.to_s.downcase # Variable suffix.
            
            @tmpl_suffixes     = devices.keys
            @tmpl_var_suffixes = devices.keys.map &:downcase
            
            params.each { |k,v| instance_variable_set :"@tmpl_#{k.to_s.downcase}", v }
            
            @dvTP = "dvTP_#{@tmpl_suffix}"
            
            # Inject suffix into Hash for helper methods.
            Hash.instance_variable_set :@tmpl_suffix, @tmpl_suffix
            Hash.instance_variable_set :@tmpl_var_suffix, @tmpl_var_suffix
          }
          
          block.call m if block_given?
        end
        
        # Generate files.
        template_files.each do |path|
            file_base_name = File.basename(path).gsub(/\..*/, '')
            output_dir = File.expand_path "#{template_dir}/.."
            output_path = "#{output_dir}/#{file_base_name}-#{name.to_s.downcase.gsub('_', '-')}.axi"
            
            puts '   ' + output_path.gsub(Dir.pwd, '')[1..-1] # Print canonical path.
            File.write output_path, execute(path, binding: b)
        end
      end
    end
    
  end
end
