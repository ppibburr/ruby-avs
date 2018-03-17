$: << File.join(File.dirname(__FILE__), "..")

require 'json'
require 'avs/util/post'

module AVS
  class SpeechRecognizer
    API = {
      1=> {
        url:     "https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize",
        request: {
          "messageHeader": {
            "deviceContext": [
              {
                "name": "playbackState",
                "namespace": "AudioPlayer",
                "payload": {
                "streamId": "",
                  "offsetInMilliseconds": "0",
                  "playerActivity": "IDLE"
                }
              }
            ]
          },
          "messageBody": {
            "profile": "alexa-close-talk",
            "locale": "en-us",
            "format": "audio/L16; rate=16000; channels=2"
          }
        }
      }
    }
    
    attr_reader :token
    def initialize token
      @token = token
    end

    def recognize input, version: 1
      File.open('./recognize_request.json', 'w') do |f|
        f.puts(API[version][:request].to_json)
      end
       
      #result = open('result').read
      result = post input, version: version 
      
      if result.scrub =~ /Content-Type: application\/json\r\n\r\n(.*)\r\n/
        begin
          obj = JSON.parse($1)
        rescue
        end
      end      
      
      [obj, result]     
    end
    
    private
    def post input, version: 1
      case version
      when 1
        Util::Post.post(API[1][:url], files: {
          metadata: {
            path:    './recognize_request.json',
            type:    'application/json',
            charset: 'UTF-8'
          },    
          
          audio: {
            type: 'audio/L16',
            path: input,
            rate: 16000,
            channels: 1
          }
        }, headers: {
          Authorization: "Bearer #{token}"
        })
        
      when 2
        raise "V2 Not implemented"   
      else
        raise "Unsupported api version: #{version}"
      end
    end
  end
end