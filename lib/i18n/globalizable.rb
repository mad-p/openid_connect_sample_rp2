module I18n
  module Globalizable
    def t(options = {})
      I18n.t(self, options.merge(default: self.split('.').last))
    end
  end
end
