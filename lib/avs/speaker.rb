module AVS
  class Speaker
    def set_mute directive, content=nil
      Util.log :SPEAKER, "mute: #{directive['payload']['mute']}"
      _mute directive['payload']['mute']
    end
    
    private 
    def _mute mute
      
    end
  end
end
