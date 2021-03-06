reload_ohai = false

unless Ohai::Config[:plugin_path].include?(node['ohai']['plugin_path'])
	#Ohai::Config[:plugin_path] << node['ohai']['plugin_path']
	Ohai::Config[:plugin_path] = [node['ohai']['plugin_path'], Ohai::Config[:plugin_path]].flatten.compact
	reload_ohai ||= true
end
Chef::Log.info("Ohai plugins will be at: #{node['ohai']['plugin_path']}")

Chef::Log.info("Ohai plugins: #{node['ohai']['plugins']}")

node['ohai']['plugins'].each_pair do |source_cookbook, path|
	
	rd = remote_directory node['ohai']['plugin_path'] do
		source path
		mode '0755'
		recursive true
		purge false
		action :nothing
	end

	rd.run_action(:create)
	reload_ohai ||= rd.updated?

end

resource = ohai 'custom_plugins' do
	action :nothing
end

# Reload only if new plugins or node['ohai']['plugin_path'] doesn't exist
if reload_ohai #||
	resource.run_action(:reload)
end