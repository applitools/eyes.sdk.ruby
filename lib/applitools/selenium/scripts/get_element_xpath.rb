# frozen_string_literal: true

module Applitools
  module Selenium
    module Scripts
      GET_ELEMENT_XPATH_JS = <<'END'
        var el = arguments[0];
        var xpath = '';
        do {
          var parent = el.parentElement;
          var index = 1;
          if (parent !== null) {
            var children = parent.children;
            for (var childIdx in children) {
              var child = children[childIdx];
              if (child === el) break;
              if (child.tagName === el.tagName) index++;
            }
          }
          xpath = '/' + el.tagName + '[' + index + ']' + xpath;
          el = parent;
        } while (el !== null);
        return '/' + xpath;
END
    end
  end
end
