class String

  # Returns a Hash of words and their frequencies
  def word_hash
    split_words.each_with_object({}) do |word, hash|
      word.downcase!
      if !word.stopword?
        hash[word] ||= 0
        hash[word] += 1
      end
    end
  end

  def split_words
    gsub(/[^\w\s]+/," ").split
  end

  def stopword?
    STOPWORDS.include? self
  end

  private

  STOPWORDS = [
    "a",
    "again",
    "all",
    "along",
    "are",
    "also",
    "an",
    "and",
    "as",
    "at",
    "but",
    "by",
    "came",
    "can",
    "cant",
    "couldnt",
    "did",
    "didn",
    "didnt",
    "do",
    "doesnt",
    "dont",
    "ever",
    "first",
    "from",
    "have",
    "her",
    "here",
    "him",
    "how",
    "i",
    "if",
    "in",
    "into",
    "is",
    "isnt",
    "it",
    "itll",
    "just",
    "last",
    "least",
    "like",
    "most",
    "my",
    "new",
    "no",
    "not",
    "now",
    "of",
    "on",
    "or",
    "should",
    "sinc",
    "so",
    "some",
    "th",
    "than",
    "this",
    "that",
    "the",
    "their",
    "then",
    "those",
    "to",
    "told",
    "too",
    "true",
    "try",
    "until",
    "url",
    "us",
    "were",
    "when",
    "whether",
    "while",
    "with",
    "within",
    "yes",
    "you",
    "youll",
    ].freeze

end
