FactoryBot.define do
  factory :user do
    member
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    activated { true }
    activated_at { activated ? Faker::Time.between(from: 1.year.ago, to: Time.zone.now) : nil }
    public { Faker::Boolean.boolean }
    subscribing { Faker::Boolean.boolean(true_ratio: 0.8) }

    trait :inactivated do
      activated { false }
    end

    transient do
      songs { [] }
    end

    after(:create) do |user, evaluator|
      evaluator.songs.each do |song|
        create(:playing, song: song, member: user.member)
      end
    end

    factory :admin do
      admin { true }
    end
  end
end
