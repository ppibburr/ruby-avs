module AVS
  class Speaker
    def set_mute directive, content=nil
      _mute directive['payload']['mute']
    end
    
    private 
    def _mute mute
      
    end
  end
end
