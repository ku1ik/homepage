module Admin
  class Plugins < Base
    before :find_plugin, :only => %w(update delete show)

    def index
      @plugins = Plugin.all
      display @plugins
    end

    def show(id)
      display @plugin
    end

    def new
      @plugin = Plugin.new
      display @plugin
    end

    def create(plugin)
      @plugin = Plugin.new
      @plugin.url = plugin[:url]
      if @plugin.save
        # Check to see if the plugin has any views registered, if so we'll expire the cache
        expire_all_pages if Hooks::View.has_views_registered?(@plugin)
        redirect url(:admin_plugin, @plugin)
      else
        render :new
      end
    end

    def update(id)
      #merb-action-args doesn't appear to play nice with ajax calls, so we're using params for the plugin active flag
      @plugin = Plugin[id]
      @plugin.active = params[:active] == "true" if params[:active]
      @plugin.save
      # Check to see if the plugin has any views registered, if so we'll need to expire all pages to be safe
      expire_all_pages if Hooks::View.has_views_registered?(@plugin)
      render_js
    end

    def delete(id)
      @plugin.destroy
      redirect url(:admin_plugins)
    end

    private
      def find_plugin
        @plugin = Plugin[params[:id]]
      end
  end
end
