module CheckIn

  _dir = 'cucumber/pickles/steps/check_in/'

  autoload :Factory,      _dir + 'factory'
  autoload :Input,        _dir + 'input'
  autoload :Text,         _dir + 'text'
  autoload :Select,       _dir + 'select'
  autoload :Image,        _dir + 'image'
  autoload :Video,        _dir + 'video'
  autoload :ComplexInput, _dir + 'complex_input'

end
