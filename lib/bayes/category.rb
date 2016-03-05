module Bayes
  class Category
    MIN_SCORE = 0.0000001

    def initialize
      reset
    end

    def reset
      @words = {}
      @words_count = 0
    end

    def train(text)
      text.word_hash.each do |word, count|
        @words[word] = @words[word].to_i + count
        @words_count += count
      end
    end

    def forget(text)
      text.word_hash.each do |word, count|
        @words[word] = @words[word].to_i - count
        @words.delete(word) if @words[word] == 0
        @words_count -= count
      end
    end

    def apply_weighting(coeff)
      top_words.each do |word|
        apply_weighting_for word, coeff
      end
    end

    def apply_weighting_for(word, coeff)
      if old_weight = @words[word]
        @words[word] = old_weight * coeff
        @words_count += @words[word] - old_weight
      end
    end

    def top_words(num = 100)
      @words.sort_by{ |w,c| -c }.slice(0,num).map{ |w| w[0] }
    end

    def score_for(words)
      if @words_count > 0
        words = words.word_hash.keys unless words.is_a? Array

        if words.any?
          words.map do |word|
            word_value = @words[word] || MIN_SCORE
            Math.log(word_value / @words_count.to_f)
          end.inject(:+)
        else
          Math.log(MIN_SCORE / @words_count)
        end
      else
        -Float::INFINITY
      end
    end

    def blank?
      @words_count == 0
    end
  end
end
