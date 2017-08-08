# original code:
#
# (function() {
#   var oldOpen = XMLHttpRequest.prototype.open;
#   window.openHTTPs = 0;
#   XMLHttpRequest.prototype.open = function(method, url, async, user, pass) {
#     window.openHTTPs++;
#     this.addEventListener("readystatechange", function() {
#         if(this.readyState == 4) {
#           window.openHTTPs--;
#         }
#       }, false);
#     oldOpen.call(this, method, url, async, user, pass);
#   }
# })(XMLHttpRequest);
#
# module Capybara
#   module Selenium
#     class Driver
#
#       class << self
#         alias __pickles_redefined__new new
#
#         #
#         # Monkey patch initializer to load custom chrome extension in extensions/chrome
#         #
#         # It will add window.activeRequests to keep track of active AJAX requests in tests
#         #
#         # For source code of extension see extensions/chrome/src/inject/inject.js
#         #
#         # TODO: support all major browser drivers
#         #
#         def new(app, options={})
#           if options[:browser].to_s == "chrome"
#             options[:desired_capabilities] ||= {}
#             options[:desired_capabilities]["chromeOptions"] ||= {}
#             options[:desired_capabilities]["chromeOptions"]["extensions"] ||= []
#
#             extension_path = File.expand_path('extensions/chrome/compiled.crx.base64', __dir__)
#
#             options[:desired_capabilities]["chromeOptions"]["extensions"].unshift(File.read(extension_path))
#           end
#
#           __pickles_redefined__new(app, options)
#         end
#       end
#
#     end
#
#   end
# end

def stub_xml_http_request(page)
  page.evaluate_script <<-JAVASCRIPT
    (function() {

      if (window.ajaxRequestIsSet) { return; };
      window.ajaxRequestIsSet = true;

      console.log(angular);

      var oldOpen = XMLHttpRequest.prototype.open;
      window.activeRequests =  0;
      XMLHttpRequest.prototype.open = function(method, url, async, user, pass) {
        window.activeRequests++;
        this.addEventListener("readystatechange", function() {
            if(this.readyState == 4) {
              window.activeRequests--;
            }
          }, false);
        oldOpen.call(this, method, url, async, user, pass);
      };


      var style = document.createElement('style');
      style.type = 'text/css';
      style.innerHTML = '* {' +
      '/*CSS transitions*/' +
      ' -o-transition-property: none !important;' +
      ' -moz-transition-property: none !important;' +
      ' -ms-transition-property: none !important;' +
      ' -webkit-transition-property: none !important;' +
      '  transition-property: none !important;' +
      '/*CSS transforms*/' +
      '  -o-transform: none !important;' +
      ' -moz-transform: none !important;' +
      '   -ms-transform: none !important;' +
      '  -webkit-transform: none !important;' +
      '   transform: none !important;' +
      '  /*CSS animations*/' +
      '   -webkit-animation: none !important;' +
      '   -moz-animation: none !important;' +
      '   -o-animation: none !important;' +
      '   -ms-animation: none !important;' +
      '   animation: none !important;}';
         document.getElementsByTagName('head')[0].appendChild(style);

    })();
  JAVASCRIPT
end

module Capybara
  class Session

    alias __pickles_redefined__old_visit visit

    def visit(*args)
      __pickles_redefined__old_visit(*args)

      stub_xml_http_request(Capybara.current_session)
    end

  end
end
module Waiter

  module_function

  def wait
    wait_for_ajax

    return unless block_given?

    page.document.synchronize do
      yield
    end
  end

  def page
    Capybara.current_session
  end

  def wait_for_ajax
    page.document.synchronize do
      pending_ajax_requests_num.zero? || raise(Capybara::ElementNotFound)
    end
  end

  def pending_ajax_requests_num
    page.evaluate_script("window.activeRequests")
  end

end
