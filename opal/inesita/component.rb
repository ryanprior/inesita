module Inesita
  module Component
    include VirtualDOM::DOM
    include ComponentHelpers
    include ComponentVirtualDomExtension
    include Injection

    def render
      raise Error, "Implement #render in #{self.class} component"
    end

    def mount_to(element)
      raise Error, "Can't mount #{self.class}, target element not found!" unless element
      inject(:root_component, self)
      @virtual_dom = render_virtual_dom
      @root_node = VirtualDOM.create(@virtual_dom)
      Browser.append_child(element, @root_node)
      self
    end

    def render_if_root
      return unless @virtual_dom && @root_node
      new_virtual_dom = render_virtual_dom
      diff = VirtualDOM.diff(@virtual_dom, new_virtual_dom)
      VirtualDOM.patch(@root_node, diff)
      @virtual_dom = new_virtual_dom
    end

    def before_render; end;

    def render_virtual_dom
      before_render
      @cache_component_counter = 0
      @__virtual_nodes__ = []
      render
      if @__virtual_nodes__.one?
        @__virtual_nodes__.first
      else
        VirtualDOM::VirtualNode.new('div', {}, @__virtual_nodes__).to_n
      end
    end

    def cache_component(component, &block)
      @cache_component ||= {}
      @cache_component_counter ||= 0
      @cache_component_counter += 1
      @cache_component["#{component}-#{@cache_component_counter}"] || @cache_component["#{component}-#{@cache_component_counter}"] = block.call
    end

    def hook(mthd)
      VirtualDOM::Hook.method(method(mthd))
    end

    def unhook(mthd)
      VirtualDOM::UnHook.method(method(mthd))
    end

    attr_reader :props
    def with_props(props)
      @props = props
      self
    end
  end
end
