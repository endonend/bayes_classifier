# Bayes::Classifier

Bayes::Classifier allows you to classify strings with naive Bayes classifier.

Note: This gem is a forked version of DarthSim's original gem to improve series and issue number matching for a project I am working on. The original had a word character minimum, which ignored numbers below 100.

## Installation

Just add the following line to your `Gemfile`:

```ruby
gem 'bayes_classifier' , :git => "git://github.com/endonend/bayes_classifier.git"
```

Then run 'bundle install'.

## Usage

```ruby
# Create new classifier
classifier = Bayes::Classifier.new

# Train classifier with a string
classifier.train :category1, "lorem ipsum dolor sit amet"

# Train classifier with array of strings
classifier.train_with_array :category2, ["the first string", "the second string", "the third string"]

# Train classifier with textfile
classifier.train_with_file :category3, "data/category3.txt"

# Train classifier with CSV file (first column - string, second column - category)
classifier.train_with_csv "data/training.csv"

# Apply weighting to the top words of category
classifier.apply_weighting :category3, 10

# Remove empty categories
classifier.pop_unused

# Classify string
classifier.classify "the string"

# Reset categories
classifier.flush

# Remove all categories
classifier.flush_all
```

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
