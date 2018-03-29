module AVS
  module Util
    class Post
      attr_reader :url, :headers, :files
      def initialize url, headers: {}, files: {}
        @files   = files
        @headers = headers
        @url     = url
      end
      
      def send
         f = files.map do |k,v|
           "-F '#{k}=<#{v[:path]};type=#{v[:type]};#{v.keys.find_all do |q| ![:type,:path].index(q) end.map do |kk| "#{kk}=#{v[kk]}" end.join(";")}'"
         end.join(" ") 
         
        cmd = "curl -i --trace-ascii z.out  "+
        "-o - "+
         "#{headers.each_pair.map do |k,v|  "-H '#{k}: #{v}'" end.join(" ")} "+
         "#{f} "+
        "'#{url}'"
        
        # puts cmd if true
        
        IO.popen(cmd, "rb+").read
      end
      
      def self.post url, files: {}, headers: {}
        Post.new(url, files: files, headers: headers).send
      end
    end
  end
end

