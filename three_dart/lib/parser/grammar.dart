import 'simple.dart' as simple;

/// A grammar is a definition of a language.
/// It is made up of a set of terms and the rules for how each term is used.
///
/// Formally a Grammar is defined as `G = (V, E, R, S)`:
/// - `V` is the set of `v` (non-terminal characters / variables).
///   These are referred to as the terms of the grammar in this implementation.
/// - `E` (normally shown as an epsilon) is the set of `t` (terminals / tokens).
///   These are referred to as the tokens of this grammar in this implementation.
///   `V` and `E` are disjoint, meaning no `v` exists in `E` and no `t` exists in `V`.
/// - `R` is the relationship of `V` to `(V union E)*`, where here the asterisk is
///   the Kleene star operation. Each `r` in `R` is a rule (rewrite rules / productions)
///   of the grammar as represented by `v → [v or t]*` where `[v or t]` is an item in
///   in the rule. Each term must be the start of one or more rules with, at least
///   one rule must contain a single item. Each term may include a rule with no items
///   (`v → ε`). There should be no duplicate rules for a term.
/// - `S` is the start term where `S` must exist in `V`.
///
/// For the LR1 parser, used by Petite Parser Dart, the grammar must be a Context-free
/// Language (CFL) where `L(G) = {w in E*: S => w}`, meaning that all non-terminals can be
/// reached (`=>` means reachable) from the start term following the rules of the grammar.
///
/// To be a _proper_ CFG there my be no unreachable terms (for all `N` in `V` there
/// exists an `a` and `b` in `(V union U)*` such that `S => a N b`), no unproductive
/// symbols (for all `N` in `V` there exists a `w` in `E*` such that `N => w`),
/// no ε-rules (there does not exist an `N` in `V` such that `N → ε` exist in `R`), and
/// there are no cycles (there does not exist an `N` in `V` such that `N => ... => N`).
///
/// For more information see https://en.wikipedia.org/wiki/Context-free_grammar
class Grammar {
  final Set<Term> _terms = {};
  final Set<TokenItem> _tokens = {};
  final Set<Trigger> _triggers = {};
  Term? _start;

  /// Creates a new empty grammar.
  Grammar();

  /// Deserializes the given serialized data into a grammar.
  factory Grammar.deserialize(simple.Deserializer data) {
    final version = data.readInt();
    if (version != 1) throw Exception('Unknown version, $version, for grammar serialization.');
    final grammar = Grammar();
    grammar.start(data.readStr());
    final termCount = data.readInt();
    for (int i = 0; i < termCount; i++) {
      final term = grammar.term(data.readStr());
      final ruleCount = data.readInt();
      for (int j = 0; j < ruleCount; j++) {
        final rule = term.newRule();
        final itemCount = data.readInt();
        for (int k = 0; k < itemCount; k++) {
          final itemType = data.readInt();
          final itemName = data.readStr();
          switch (itemType) {
            case 1:
              rule.addTerm(itemName);
              break;
            case 2:
              rule.addToken(itemName);
              break;
            case 3:
              rule.addTrigger(itemName);
              break;
          }
        }
      }
    }
    return grammar;
  }

  /// Creates a copy of this grammar.
  Grammar copy() {
    final grammar = Grammar();
    for (final term in this._terms) {
      grammar._add(term.name);
    }
    if (this._start != null) grammar._start = grammar._findTerm(this._start?.name ?? '');
    for (final term in this._terms) {
      final termCopy = grammar._findTerm(term.name);
      if (termCopy != null) {
        for (final rule in term.rules) {
          final ruleCopy = Rule._(grammar, termCopy);
          for (final item in rule.items) {
            Item itemCopy;
            if (item is Term) {
              itemCopy = grammar.term(item.name);
            } else if (item is TokenItem) {
              itemCopy = grammar.token(item.name);
            } else if (item is Trigger) {
              itemCopy = grammar.trigger(item.name);
            } else {
              throw Exception('Unknown item type: $item');
            }
            ruleCopy._items.add(itemCopy);
          }
          termCopy.rules.add(ruleCopy);
        }
      }
    }
    return grammar;
  }

  /// Serializes the grammar.
  simple.Serializer serialize() {
    final data = simple.Serializer();
    data.writeInt(1); // Version 1
    data.writeStr(this._start?.name ?? '');
    data.writeInt(this._terms.length);
    for (final term in this._terms) {
      data.writeStr(term.name);
      data.writeInt(term.rules.length);
      for (final rule in term.rules) {
        data.writeInt(rule.items.length);
        for (final item in rule.items) {
          final int itemType;
          if (item is Term) {
            itemType = 1;
          } else {
            if (item is TokenItem) {
              itemType = 2;
            } else {
              itemType = 3;
            }
          }
          data.writeInt(itemType);
          data.writeStr(item.name);
        }
      }
    }
    return data;
  }

  /// This will trim the term name and check if the name is empty.
  String _sanitizedTermName(String name) {
    // ignore: parameter_assignments
    name = name.trim();
    if (name.isEmpty) throw Exception('May not have an all whitespace or empty term name.');
    return name;
  }

  /// Creates or adds a term for a set of rules
  /// and sets it as the starting term for the grammar.
  Term start(String termName) => this._start = this.term(termName);

  /// Gets the start term for this grammar.
  Term? get startTerm => this._start;

  /// Gets the terms for this grammar.
  List<Term> get terms => this._terms.toList();

  /// Gets the tokens for this grammar.
  List<TokenItem> get tokens => this._tokens.toList();

  /// Gets the triggers for this grammar.
  List<Trigger> get triggers => this._triggers.toList();

  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term? _findTerm(String termName) {
    for (final term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  /// Adds a new term to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term _add(String termName) {
    final nt = Term._(this, termName);
    this._terms.add(nt);
    this._start ??= nt;
    return nt;
  }

  /// Find the existing token in this grammar
  /// or add it if not found.
  TokenItem token(String tokenName) {
    // ignore: parameter_assignments
    tokenName = tokenName.trim();
    if (tokenName.isEmpty) throw Exception('May not have an all whitespace or empty token name.');
    for (final token in this._tokens) {
      if (token.name == tokenName) return token;
    }
    final token = TokenItem(tokenName);
    this._tokens.add(token);
    return token;
  }

  /// Find the existing trigger in this grammar
  /// or add it if not found.
  Trigger trigger(String triggerName) {
    // ignore: parameter_assignments
    triggerName = triggerName.trim();
    if (triggerName.isEmpty) throw Exception('May not have an all whitespace or empty trigger name.');
    for (final trigger in this._triggers) {
      if (trigger.name == triggerName) return trigger;
    }
    final trigger = Trigger(triggerName);
    this._triggers.add(trigger);
    return trigger;
  }

  /// Gets or adds a term for a set of rules to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term term(String termName) {
    // ignore: parameter_assignments
    termName = this._sanitizedTermName(termName);
    Term? nt = this._findTerm(termName);
    return nt ??= this._add(termName);
  }

  /// Gets or adds a term for and starts a new rule for that term.
  /// If the start term isn't set, it will be set to this rule's term.
  /// The new rule is returned.
  Rule newRule(String termName) => this.term(termName).newRule();

  /// Gets a string showing the whole language.
  @override
  String toString() {
    final buf = StringBuffer();
    if (this._start != null) buf.writeln("> " + this._start.toString());
    for (final term in this._terms) {
      // ignore: prefer_foreach
      for (final rule in term.rules) {
        buf.writeln(rule);
      }
    }
    return buf.toString();
  }

  /// Validates the grammars configuration,
  /// on success (no errors) an empty string is returned,
  /// on failure a string containing each error line separated is returned.
  String validate() {
    final buf = StringBuffer();
    if (this._terms.isEmpty) buf.writeln('No terms are defined.');
    if (this._tokens.isEmpty) buf.writeln('No tokens are defined.');
    if (this._start == null) {
      buf.writeln('The start term is not set.');
    } else if (!this._terms.contains(this._start)) {
      buf.writeln('The start term, ${this._start}, was not found in the set of terms.');
    }
    final termList = this._terms.toList();
    for (int i = termList.length - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        if (termList[i].name == termList[j].name) {
          buf.writeln('There exists two terms with the same name, ${termList[i].name}.');
        }
      }
    }
    for (final term in this._terms) {
      if (term.name.trim().isEmpty) buf.writeln('There exists a term which is all whitespace or empty.');
      if (term._rules.isEmpty) buf.writeln('The term, $term, has no rules defined for it.');
      for (int i = term._rules.length - 1; i >= 0; i--) {
        for (int j = i - 1; j >= 0; j--) {
          if (term._rules[i].equals(term._rules[j])) {
            buf.writeln('There exists two rules which are the same, ${term._rules[i].toString()}.');
          }
        }
      }
      for (final rule in term._rules) {
        if (rule.term == null) {
          buf.writeln('The rule for ${term.name} is rule.');
        } else if (rule.term != term) {
          buf.writeln('The rule for ${term.name} says it is for ${rule.term?.name ?? 'null'}.');
        }
        for (final item in rule._items) {
          if (item.name.trim().isEmpty) {
            buf.writeln('There exists an item in rule for ${term.name} which is all whitespace or empty.');
          }
          if (item is Term) {
            if (!this._terms.contains(item)) {
              buf.writeln("The term, $item, in a rule for ${term.name}, was not found in the set of terms.");
            }
          } else if (item is TokenItem) {
            if (!this._tokens.contains(item)) {
              buf.writeln('The token, $item, in a rule for ${term.name}, was not found in the set of tokens.');
            }
          } else if (item is Trigger) {
            if (!this._triggers.contains(item)) {
              buf.writeln('The trigger, $item, in a rule for ${term.name}, was not found in the set of triggers.');
            }
          } else {
            throw Exception('Unknown item type in ${term.name}.');
          }
        }
      }
    }
    final unreached = _grammarUnreached(buf, termList, this._tokens, this._triggers);
    unreached.touch(this._start);
    unreached.validate();
    return buf.toString();
  }
}

/// This is a tool to help gramar validate unreachable states.
class _grammarUnreached {
  final StringBuffer _buf;
  final Set<String> _terms = {};
  final Set<String> _tokens = {};
  final Set<String> _triggers = {};

  /// Creates and populates a new unreachable validation.
  _grammarUnreached(this._buf, List<Term> terms, Set<TokenItem> tokens, Set<Trigger> triggers) {
    this._terms.addAll(terms.map<String>((Term t) => t.name));
    this._tokens.addAll(tokens.map<String>((TokenItem t) => t.name));
    this._triggers.addAll(triggers.map<String>((Trigger t) => t.name));
  }

  /// Touches the item and all the rules and items that are reachable.
  /// Anything reached is removed to leave only the unreachables.
  void touch(Item? item) {
    if (item == null) return;
    if (item is Term) {
      if (this._terms.contains(item.name)) {
        this._terms.remove(item.name);
        for (final r in item._rules) {
          // ignore: prefer_foreach
          for (final item in r._items) {
            this.touch(item);
          }
        }
      }
    } else if (item is TokenItem) {
      this._tokens.remove(item.name);
    } else if (item is Trigger) {
      this._triggers.remove(item.name);
    } else {
      _buf.writeln('Unknown item type: $item');
    }
  }

  /// Validates the unreachable and writes errors to the buffer.
  void validate() {
    if (this._terms.isNotEmpty) _buf.writeln('The following terms are unreachable: ${this._terms.join(', ')}');
    if (this._tokens.isNotEmpty) _buf.writeln('The following tokens are unreachable: ${this._tokens.join(', ')}');
    if (this._triggers.isNotEmpty) _buf.writeln('The following triggers are unreachable: ${this._triggers.join(', ')}');
  }
}

/// A trigger is an optional item which can be added
/// to a parse that is carried through to the parse results.
/// The triggers can used when compiling or interpreting.
class Trigger extends Item {
  /// Creates a new trigger.
  Trigger(String name) : super._(name);

  /// Gets the string for this trigger.
  @override
  String toString() => "{${this.name}}";
}

/// A token is an item to represent a group of text
/// to the parser so it can match tokens to determine the
/// different rules to take while parsing.
/// This mirrors the `Tokenizer.Token` result object.
class TokenItem extends Item {
  /// Creates a new token.
  TokenItem(String name) : super._(name);

  /// Gets the string for this token.
  @override
  String toString() => "[${this.name}]";
}

/// A term is a group of rules and part of a rule
/// which defines part of the grammar language.
///
/// For example the term `<T>` with the rules `<T> => "(" <E> ")"`,
/// `<T> => <E> * <E>`, and `<T> => <E> + <E>`.
class Term extends Item {
  final Grammar _grammar;
  final List<Rule> _rules = [];

  /// Creates a new term with the given name for the given grammar.
  Term._(this._grammar, String name) : super._(name);

  /// Gets the list of rules starting with this term.
  List<Rule> get rules => this._rules;

  /// Adds a new rule to this term.
  Rule newRule() {
    final rule = Rule._(this._grammar, this);
    this._rules.add(rule);
    return rule;
  }

  /// Determines the first tokens that can be reached from
  /// the rules of this term.
  List<TokenItem> determineFirsts() {
    final tokens = <TokenItem>{};
    this._determineFirsts(tokens, <Term>{});
    return tokens.toList();
  }

  /// Determines the follow tokens that can be reached from the reduction of all the rules,
  /// i.e. the tokens which follow after the term and any first term in all the rules.
  List<TokenItem> determineFollows() {
    final tokens = <TokenItem>{};
    this._determineFollows(tokens, <Term>{});
    return tokens.toList();
  }

  /// This is the recursive part of the determination of the first token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFirsts(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    bool needFollows = false;
    for (final rule in this._rules) {
      if (this._determineRuleFirsts(rule, tokens, checked)) needFollows = true;
    }
    if (needFollows) this._determineFollows(tokens, <Term>{});
  }

  /// This determines the firsts for the given rule.
  /// If the rule has no tokens or terms this will return true
  /// indicating that the rule needs follows to be added.
  bool _determineRuleFirsts(Rule rule, Set<TokenItem> tokens, Set<Term> checked) {
    for (final item in rule.items) {
      if (item is Term) {
        item._determineFirsts(tokens, checked);
        return false;
      } else if (item is TokenItem) {
        tokens.add(item);
        return false;
      }
      // else if Trigger continue.
    }
    return true;
  }

  /// This is the recursive part of the determination of the follow token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFollows(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    for (final term in this._grammar.terms) {
      for (final rule in term.rules) {
        final items = rule.basicItems;
        final count = items.length;
        for (int i = 0; i < count - 1; i++) {
          if (items[i] == this) {
            final item = items[i + 1];
            if (item is Term) {
              item._determineFirsts(tokens, <Term>{});
            } else {
              tokens.add(item as TokenItem);
            }
          }
        }

        if ((items.isNotEmpty) && (items[count - 1] == this)) {
          term._determineFollows(tokens, checked);
        }
      }
    }
  }

  /// Gets the string for this term.
  @override
  String toString() => "<${this.name}>";
}

/// A rule is a single definition from a grammar.
///
/// For example `<T> → "(" <E> ")"`. The term for the rule is
/// the left hand side (`T`) while the items are the parts on the right hand size.
/// The items are made up of tokens (`(`, `)`) and the rule's term or other terms (`E`).
/// The order of the items defines how this rule in the grammar is to be used.
class Rule {
  final Grammar _grammar;
  final Term? _term;
  final List<Item> _items = [];

  /// Creates a new rule for the the given grammar and term.
  Rule._(this._grammar, Term this._term);

  /// Adds a term to this rule.
  /// This will get or create a new term to the grammar.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addTerm(String termName) {
    final term = this._grammar.term(termName);
    this._items.add(term);
    return this;
  }

  /// Adds a token to this rule.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addToken(String tokenName) {
    final token = this._grammar.token(tokenName);
    this._items.add(token);
    return this;
  }

  /// Adds a trigger to this rule.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addTrigger(String triggerName) {
    final trigger = this._grammar.trigger(triggerName);
    this._items.add(trigger);
    return this;
  }

  /// Gets the left hand side term to the rule.
  Term? get term => this._term;

  /// Gets all the terms, tokens, and triggers for this rule.
  /// The items are in the order defined by this rule.
  List<Item> get items => this._items;

  /// Gets the set of terms and tokens without the triggers.
  List<Item> get basicItems {
    final items = <Item>[];
    for (final item in this._items) {
      if (item is! Trigger) items.add(item);
    }
    return items;
  }

  /// Determines if the given rule is equal to this rule.
  /// This uses pointer comparison for item equivalency.
  bool equals(Rule? other) {
    if (other == null) return false;
    if (this._term != other._term) return false;
    if (this._items.length != other._items.length) return false;
    for (int i = this._items.length - 1; i >= 0; i--) {
      if (this._items[i] != other._items[i]) return false;
    }
    return true;
  }

  /// Gets the string for this rule.
  /// Has an optional step index for showing the different
  /// states of the parser generator.
  @override
  String toString([int stepIndex = -1]) {
    final parts = <String>[];
    int index = 0;
    for (final item in this._items) {
      if (index == stepIndex) {
        parts.add('•');
        // ignore: parameter_assignments
        stepIndex = -1;
      }
      parts.add(item.toString());
      if (item is! Trigger) index++;
    }
    if (index == stepIndex) parts.add('•');
    return this._term.toString() + ' → ' + parts.join(' ');
  }
}

/// An item is part of a term rule.
abstract class Item {
  /// The name of the item.
  final String name;

  /// Creates a new item.
  Item._(this.name);

  /// Gets the string for this item.
  @override
  String toString() => this.name;
}
