def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

# Colourful outputs!
class String
	def blink; "\e[5m#{self}\e[0m"; end
	def reverse; "\e[7m#{self}\e[0m"; end
	def concealed; "\e[8m#{self}\e[0m"; end
	def black; "\e[30m#{self}\e[0m"; end
	def red; "\e[31m#{self}\e[0m"; end
	def green; "\e[32m#{self}\e[0m"; end
  def yellow; "\e[33m#{self}\e[0m"; end
  def blue; "\e[34m#{self}\e[0m"; end
  def magenta; "\e[35m#{self}\e[0m"; end
  def cyan; "\e[36m#{self}\e[0m"; end
  def white; "\e[37m#{self}\e[0m"; end
end