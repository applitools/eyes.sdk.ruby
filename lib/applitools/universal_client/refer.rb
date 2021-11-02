require('securerandom')

module Applitools::UniversalClient
  class Refer
    attr_reader :store, :relation
    REF_ID = 'applitools-ref-id'.freeze

    def initialize()
      @store = {}
      @relation = {}
    end

    def ref(value, parentRef = nil)
      uuid = SecureRandom.uuid
      store[uuid] = value
      if (parentRef)
        childRefs = relation[parentRef[:REF_ID]]
        if (!childRefs)
          childRefs = []
          childRefs.push(uuid)
          relation[parentRef[REF_ID]] = childRefs
        else
          childRefs.push(uuid)
        end
      end
      {REF_ID => uuid}
    end

    def isRef(ref)
      !ref.nil? && ref.respond_to?(:keys) && !!destructure_ref(ref)
    end

    def deref(ref)
      isRef(ref) ? store[destructure_ref(ref)] : ref
    end
    
    def destroy(ref)
      return if (!isRef(ref))
      childRefs = relation[destructure_ref(ref)]
      childRefs.each{|childRef| destroy({REF_ID => childRef})} if childRefs
      store.delete(destructure_ref(ref))
    end

    def deref_all(input)
      if (isRef(input))
        deref(input)
      elsif (input.is_a?(Array))
        input.map {|arg| isRef(arg) ? deref(arg) : deref_all(arg)}
      elsif (input.is_a?(Hash))
        r = {}
        input.each_pair {|k,v| r[k] = isRef(v) ? deref(v) : v}
        r
      else
        input
      end
    end

    def ref_all(input, qualifier = ->(i) {})
      if (input.is_a? Array)
        input.map {|i| qualifier.call(i) ? ref(i) : i} 
      else
        input
      end
    end

    private

      def destructure_ref(ref)
        ref.keys.first.is_a?(Symbol) ? ref[:"#{REF_ID}"] : ref[REF_ID]
      end
  end
end
