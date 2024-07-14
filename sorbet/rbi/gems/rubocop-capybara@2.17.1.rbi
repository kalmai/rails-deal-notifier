# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rubocop-capybara` gem.
# Please instead update this file by running `bin/tapioca gem rubocop-capybara`.


# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#3
module RuboCop; end

# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#4
module RuboCop::Cop; end

# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#5
module RuboCop::Cop::Capybara; end

# Help methods for capybara.
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#7
module RuboCop::Cop::Capybara::CapybaraHelp
  private

  # @example
  #   common_attributes?('a[focused]') # => true
  #   common_attributes?('button[focused][visible]') # => true
  #   common_attributes?('table[id=some-id]') # => true
  #   common_attributes?('h1[invalid]') # => false
  # @param selector [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#60
  def common_attributes?(selector); end

  # @param node [RuboCop::AST::SendNode]
  # @param option [Symbol]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#124
  def include_option?(node, option); end

  # @example
  #   replaceable_attributes?('table[id=some-id]') # => true
  #   replaceable_attributes?('a[focused]') # => false
  # @param attrs [Array<String>]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#69
  def replaceable_attributes?(attrs); end

  # @param node [RuboCop::AST::SendNode]
  # @param element [String]
  # @param attrs [Array<String>]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#107
  def replaceable_element?(node, element, attrs); end

  # @param node [RuboCop::AST::SendNode]
  # @param locator [String]
  # @param element [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#44
  def replaceable_option?(node, locator, element); end

  # @param pseudo_class [String]
  # @param locator [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#84
  def replaceable_pseudo_class?(pseudo_class, locator); end

  # @param locator [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#95
  def replaceable_pseudo_class_not?(locator); end

  # @param locator [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#75
  def replaceable_pseudo_classes?(locator); end

  # @param node [RuboCop::AST::SendNode]
  # @param attrs [Array<String>]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#117
  def replaceable_to_link?(node, attrs); end

  class << self
    # @example
    #   common_attributes?('a[focused]') # => true
    #   common_attributes?('button[focused][visible]') # => true
    #   common_attributes?('table[id=some-id]') # => true
    #   common_attributes?('h1[invalid]') # => false
    # @param selector [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#60
    def common_attributes?(selector); end

    # @param node [RuboCop::AST::SendNode]
    # @param option [Symbol]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#124
    def include_option?(node, option); end

    # @example
    #   replaceable_attributes?('table[id=some-id]') # => true
    #   replaceable_attributes?('a[focused]') # => false
    # @param attrs [Array<String>]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#69
    def replaceable_attributes?(attrs); end

    # @param node [RuboCop::AST::SendNode]
    # @param element [String]
    # @param attrs [Array<String>]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#107
    def replaceable_element?(node, element, attrs); end

    # @param node [RuboCop::AST::SendNode]
    # @param locator [String]
    # @param element [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#44
    def replaceable_option?(node, locator, element); end

    # @param pseudo_class [String]
    # @param locator [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#84
    def replaceable_pseudo_class?(pseudo_class, locator); end

    # @param locator [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#95
    def replaceable_pseudo_class_not?(locator); end

    # @param locator [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#75
    def replaceable_pseudo_classes?(locator); end

    # @param node [RuboCop::AST::SendNode]
    # @param attrs [Array<String>]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#117
    def replaceable_to_link?(node, attrs); end
  end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#8
RuboCop::Cop::Capybara::CapybaraHelp::COMMON_OPTIONS = T.let(T.unsafe(nil), Array)

# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#11
RuboCop::Cop::Capybara::CapybaraHelp::SPECIFIC_OPTIONS = T.let(T.unsafe(nil), Hash)

# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/capybara_help.rb#34
RuboCop::Cop::Capybara::CapybaraHelp::SPECIFIC_PSEUDO_CLASSES = T.let(T.unsafe(nil), Array)

# Helps parsing css selector.
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#7
module RuboCop::Cop::Capybara::CssSelector
  private

  # @example
  #   attribute?('[attribute]') # => true
  #   attribute?('attribute') # => false
  # @param selector [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#47
  def attribute?(selector); end

  # @example
  #   attributes('a[foo-bar_baz]') # => {"foo-bar_baz=>nil}
  #   attributes('button[foo][bar=baz]') # => {"foo"=>nil, "bar"=>"'baz'"}
  #   attributes('table[foo=bar]') # => {"foo"=>"'bar'"}
  # @param selector [String]
  # @return [Array<String>]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#57
  def attributes(selector); end

  # @example
  #   classes('#some-id') # => []
  #   classes('.some-cls') # => ['some-cls']
  #   classes('#some-id.some-cls') # => ['some-cls']
  #   classes('#some-id.cls1.cls2') # => ['cls1', 'cls2']
  # @param selector [String]
  # @return [Array<String>]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#38
  def classes(selector); end

  # @example
  #   id('#some-id') # => some-id
  #   id('.some-cls') # => nil
  #   id('#some-id.cls') # => some-id
  # @param selector [String]
  # @return [String]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#16
  def id(selector); end

  # @example
  #   id?('#some-id') # => true
  #   id?('.some-cls') # => false
  # @param selector [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#27
  def id?(selector); end

  # @example
  #   multiple_selectors?('a.cls b#id') # => true
  #   multiple_selectors?('a.cls') # => false
  # @param selector [String]
  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#87
  def multiple_selectors?(selector); end

  # @example
  #   normalize_value('true') # => true
  #   normalize_value('false') # => false
  #   normalize_value(nil) # => nil
  #   normalize_value("foo") # => "'foo'"
  # @param value [String]
  # @return [Boolean, String]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#99
  def normalize_value(value); end

  # @example
  #   pseudo_classes('button:not([disabled])') # => ['not()']
  #   pseudo_classes('a:enabled:not([valid])') # => ['enabled', 'not()']
  # @param selector [String]
  # @return [Array<String>]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#73
  def pseudo_classes(selector); end

  class << self
    # @example
    #   attribute?('[attribute]') # => true
    #   attribute?('attribute') # => false
    # @param selector [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#47
    def attribute?(selector); end

    # @example
    #   attributes('a[foo-bar_baz]') # => {"foo-bar_baz=>nil}
    #   attributes('button[foo][bar=baz]') # => {"foo"=>nil, "bar"=>"'baz'"}
    #   attributes('table[foo=bar]') # => {"foo"=>"'bar'"}
    # @param selector [String]
    # @return [Array<String>]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#57
    def attributes(selector); end

    # @example
    #   classes('#some-id') # => []
    #   classes('.some-cls') # => ['some-cls']
    #   classes('#some-id.some-cls') # => ['some-cls']
    #   classes('#some-id.cls1.cls2') # => ['cls1', 'cls2']
    # @param selector [String]
    # @return [Array<String>]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#38
    def classes(selector); end

    # @example
    #   id('#some-id') # => some-id
    #   id('.some-cls') # => nil
    #   id('#some-id.cls') # => some-id
    # @param selector [String]
    # @return [String]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#16
    def id(selector); end

    # @example
    #   id?('#some-id') # => true
    #   id?('.some-cls') # => false
    # @param selector [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#27
    def id?(selector); end

    # @example
    #   multiple_selectors?('a.cls b#id') # => true
    #   multiple_selectors?('a.cls') # => false
    # @param selector [String]
    # @return [Boolean]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#87
    def multiple_selectors?(selector); end

    # @example
    #   normalize_value('true') # => true
    #   normalize_value('false') # => false
    #   normalize_value(nil) # => nil
    #   normalize_value("foo") # => "'foo'"
    # @param value [String]
    # @return [Boolean, String]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#99
    def normalize_value(value); end

    # @example
    #   pseudo_classes('button:not([disabled])') # => ['not()']
    #   pseudo_classes('a:enabled:not([valid])') # => ['enabled', 'not()']
    # @param selector [String]
    # @return [Array<String>]
    #
    # source://rubocop-capybara//lib/rubocop/cop/capybara/mixin/css_selector.rb#73
    def pseudo_classes(selector); end
  end
end

# Checks that no expectations are set on Capybara's `current_path`.
#
# The
# https://www.rubydoc.info/github/teamcapybara/capybara/main/Capybara/RSpecMatchers#have_current_path-instance_method[`have_current_path` matcher]
# should be used on `page` to set expectations on Capybara's
# current path, since it uses
# https://github.com/teamcapybara/capybara/blob/main/README.md#asynchronous-javascript-ajax-and-friends[Capybara's waiting functionality]
# which ensures that preceding actions (like `click_link`) have
# completed.
#
# This cop does not support autocorrection in some cases.
#
# @example
#   # bad
#   expect(current_path).to eq('/callback')
#
#   # good
#   expect(page).to have_current_path('/callback')
#
#   # bad (does not support autocorrection)
#   expect(page.current_path).to match(variable)
#
#   # good
#   expect(page).to have_current_path('/callback')
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#31
class RuboCop::Cop::Capybara::CurrentPathExpectation < ::RuboCop::Cop::Base
  extend ::RuboCop::Cop::AutoCorrector

  # Supported matchers: eq(...) / match(/regexp/) / match('regexp')
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#47
  def as_is_matcher(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#41
  def expectation_set_on_current_path(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#64
  def on_send(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#54
  def regexp_node_matcher(param0 = T.unsafe(nil)); end

  private

  # `have_current_path` with no options will include the querystring
  # while `page.current_path` does not.
  # This ensures the option `ignore_query: true` is added
  # except when the expectation is a regexp or string
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#118
  def add_ignore_query_options(corrector, node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#76
  def autocorrect(corrector, node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#100
  def convert_regexp_node_to_literal(corrector, matcher_node, regexp_node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#106
  def regexp_node_to_regexp_expr(regexp_node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#87
  def rewrite_expectation(corrector, node, to_symbol, matcher_node); end

  class << self
    # source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#60
    def autocorrect_incompatible_with; end
  end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#34
RuboCop::Cop::Capybara::CurrentPathExpectation::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/current_path_expectation.rb#38
RuboCop::Cop::Capybara::CurrentPathExpectation::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)

# Checks for usage of deprecated style methods.
#
# @example when using `assert_style`
#   # bad
#   page.find(:css, '#first').assert_style(display: 'block')
#
#   # good
#   page.find(:css, '#first').assert_matches_style(display: 'block')
# @example when using `has_style?`
#   # bad
#   expect(page.find(:css, 'first')
#   .has_style?(display: 'block')).to be true
#
#   # good
#   expect(page.find(:css, 'first')
#   .matches_style?(display: 'block')).to be true
# @example when using `have_style`
#   # bad
#   expect(page).to have_style(display: 'block')
#
#   # good
#   expect(page).to match_style(display: 'block')
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#31
class RuboCop::Cop::Capybara::MatchStyle < ::RuboCop::Cop::Base
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#42
  def on_send(node); end

  private

  # source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#52
  def message(node); end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#34
RuboCop::Cop::Capybara::MatchStyle::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#36
RuboCop::Cop::Capybara::MatchStyle::PREFERRED_METHOD = T.let(T.unsafe(nil), Hash)

# source://rubocop-capybara//lib/rubocop/cop/capybara/match_style.rb#35
RuboCop::Cop::Capybara::MatchStyle::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)

# Enforces use of `have_no_*` or `not_to` for negated expectations.
#
# @example EnforcedStyle: not_to (default)
#   # bad
#   expect(page).to have_no_selector
#   expect(page).to have_no_css('a')
#
#   # good
#   expect(page).not_to have_selector
#   expect(page).not_to have_css('a')
# @example EnforcedStyle: have_no
#   # bad
#   expect(page).not_to have_selector
#   expect(page).not_to have_css('a')
#
#   # good
#   expect(page).to have_no_selector
#   expect(page).to have_no_css('a')
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#26
class RuboCop::Cop::Capybara::NegationMatcher < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::ConfigurableEnforcedStyle
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#50
  def have_no?(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#44
  def not_to?(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#55
  def on_send(node); end

  private

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#78
  def message(matcher); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#69
  def offense?(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#74
  def offense_range(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#93
  def replaced_matcher(matcher); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#84
  def replaced_runner; end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#31
RuboCop::Cop::Capybara::NegationMatcher::CAPYBARA_MATCHERS = T.let(T.unsafe(nil), Array)

# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#30
RuboCop::Cop::Capybara::NegationMatcher::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#38
RuboCop::Cop::Capybara::NegationMatcher::NEGATIVE_MATCHERS = T.let(T.unsafe(nil), Set)

# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#36
RuboCop::Cop::Capybara::NegationMatcher::POSITIVE_MATCHERS = T.let(T.unsafe(nil), Set)

# source://rubocop-capybara//lib/rubocop/cop/capybara/negation_matcher.rb#41
RuboCop::Cop::Capybara::NegationMatcher::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Set)

# Checks for there is a more specific actions offered by Capybara.
#
# @example
#
#   # bad
#   find('a').click
#   find('button.cls').click
#   find('a', exact_text: 'foo').click
#   find('div button').click
#
#   # good
#   click_link
#   click_button(class: 'cls')
#   click_link(exact_text: 'foo')
#   find('div').click_button
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#22
class RuboCop::Cop::Capybara::SpecificActions < ::RuboCop::Cop::Base
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#31
  def click_on_selector(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#35
  def on_send(node); end

  private

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#87
  def good_action(action); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#73
  def last_selector(arg); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#81
  def message(action, selector); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#77
  def offense_range(node, receiver); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#57
  def replaceable?(node, arg, action); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#63
  def replaceable_attributes?(selector); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#53
  def specific_action(selector); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#69
  def supported_selector?(selector); end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#23
RuboCop::Cop::Capybara::SpecificActions::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#24
RuboCop::Cop::Capybara::SpecificActions::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_actions.rb#25
RuboCop::Cop::Capybara::SpecificActions::SPECIFIC_ACTION = T.let(T.unsafe(nil), Hash)

# Checks if there is a more specific finder offered by Capybara.
#
# @example
#   # bad
#   find('#some-id')
#   find('[visible][id=some-id]')
#
#   # good
#   find_by_id('some-id')
#   find_by_id('some-id', visible: true)
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#17
class RuboCop::Cop::Capybara::SpecificFinders < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::RangeHelp
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#31
  def class_options(param0); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#26
  def find_argument(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#35
  def on_send(node); end

  private

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#89
  def append_options(classes, options); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#63
  def attribute?(arg); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#79
  def autocorrect_classes(corrector, node, classes); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#116
  def end_pos(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#94
  def keyword_argument_class(classes); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#112
  def offense_range(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#47
  def on_attr(node, arg); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#55
  def on_id(node, arg); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#68
  def register_offense(node, id, classes = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#99
  def replaced_arguments(arg, id); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#104
  def to_options(attrs); end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#22
RuboCop::Cop::Capybara::SpecificFinders::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_finders.rb#23
RuboCop::Cop::Capybara::SpecificFinders::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)

# Checks for there is a more specific matcher offered by Capybara.
#
# @example
#
#   # bad
#   expect(page).to have_selector('button')
#   expect(page).to have_no_selector('button.cls')
#   expect(page).to have_css('button')
#   expect(page).to have_no_css('a.cls', href: 'http://example.com')
#   expect(page).to have_css('table.cls')
#   expect(page).to have_css('select')
#   expect(page).to have_css('input', exact_text: 'foo')
#
#   # good
#   expect(page).to have_button
#   expect(page).to have_no_button(class: 'cls')
#   expect(page).to have_button
#   expect(page).to have_no_link('foo', class: 'cls', href: 'http://example.com')
#   expect(page).to have_table(class: 'cls')
#   expect(page).to have_select
#   expect(page).to have_field('foo')
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#28
class RuboCop::Cop::Capybara::SpecificMatcher < ::RuboCop::Cop::Base
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#41
  def first_argument(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#45
  def on_send(node); end

  private

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#80
  def good_matcher(node, matcher); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#74
  def message(node, matcher); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#62
  def replaceable?(node, arg, matcher); end

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#68
  def replaceable_attributes?(selector); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#57
  def specific_matcher(arg); end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#29
RuboCop::Cop::Capybara::SpecificMatcher::MSG = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#30
RuboCop::Cop::Capybara::SpecificMatcher::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)

# source://rubocop-capybara//lib/rubocop/cop/capybara/specific_matcher.rb#32
RuboCop::Cop::Capybara::SpecificMatcher::SPECIFIC_MATCHER = T.let(T.unsafe(nil), Hash)

# Checks for boolean visibility in Capybara finders.
#
# Capybara lets you find elements that match a certain visibility using
# the `:visible` option. `:visible` accepts both boolean and symbols as
# values, however using booleans can have unwanted effects. `visible:
# false` does not find just invisible elements, but both visible and
# invisible elements. For expressiveness and clarity, use one of the
# symbol values, `:all`, `:hidden` or `:visible`.
# Read more in
# https://www.rubydoc.info/gems/capybara/Capybara%2FNode%2FFinders:all[the documentation].
#
# @example
#   # bad
#   expect(page).to have_selector('.foo', visible: false)
#   expect(page).to have_css('.foo', visible: true)
#   expect(page).to have_link('my link', visible: false)
#
#   # good
#   expect(page).to have_selector('.foo', visible: :visible)
#   expect(page).to have_css('.foo', visible: :all)
#   expect(page).to have_link('my link', visible: :hidden)
#
# source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#28
class RuboCop::Cop::Capybara::VisibilityMatcher < ::RuboCop::Cop::Base
  # source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#58
  def on_send(node); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#54
  def visible_false?(param0 = T.unsafe(nil)); end

  # source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#49
  def visible_true?(param0 = T.unsafe(nil)); end

  private

  # @return [Boolean]
  #
  # source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#65
  def capybara_matcher?(method_name); end
end

# source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#31
RuboCop::Cop::Capybara::VisibilityMatcher::CAPYBARA_MATCHER_METHODS = T.let(T.unsafe(nil), Array)

# source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#29
RuboCop::Cop::Capybara::VisibilityMatcher::MSG_FALSE = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#30
RuboCop::Cop::Capybara::VisibilityMatcher::MSG_TRUE = T.let(T.unsafe(nil), String)

# source://rubocop-capybara//lib/rubocop/cop/capybara/visibility_matcher.rb#46
RuboCop::Cop::Capybara::VisibilityMatcher::RESTRICT_ON_SEND = T.let(T.unsafe(nil), Array)
