class AbuseContent < ActiveRecord::Base
  belongs_to :stream
  belongs_to :user

  REASONS = {
    "The stream contains sexual content." => "PORN",
    "The stream contains violent or repulsive content." => "VIOLENCE",
    "The stream contains hateful or abusive content." => "HATE",
    "The stream contains harmful or dangerous acts." => "DANGEROUS",
    "The stream infringes on the complainant's rights or copyright." => "RIGHTS",
    "This is Spam content" => "SPAM"
  }
end
