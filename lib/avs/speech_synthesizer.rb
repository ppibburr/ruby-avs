module AVS
  class SpeechSynthesizer
    def speak directive, content
      data = content[id=directive['payload']['audioContent'].gsub('cid:', '')]
      
      _perform_speak data
    end

    private    
    def _perform_speak data
    
    end
  end
end
