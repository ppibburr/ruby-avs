module AVS
  module Util
    class STT
      def recognize path: nil, io: nil
        Util.log :STT, (path ? path : io)
        
        if self.class == STT
          raise "Virtual method called"
        end
      end
    end
    
    class WitSTT < STT
      def initialize key: nil
        @key = key
      end
      
      def recognize path: nil, io: nil
        super
        
        obj = AVS::Util.shell "curl -XPOST 'https://api.wit.ai/speech?v=20160526' -L -H \"Authorization: Bearer VM7GFFHMNBBTZZTDS5NKD43L5FW45VXE\" -H \"Content-Type: audio/wav\" -H \"Transfer-Encoding: chunked\" --data-binary @#{path} -o -", json: true
        text = obj["_text"]
        
        Util.log :STT, "Utterance: #{text}"
        
        text
      end
    end
  end
end
