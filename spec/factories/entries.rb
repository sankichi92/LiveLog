FactoryBot.define do
  factory :entry, class: 'Entry' do
    association :applicant, factory: :user
    association :song, factory: %i[song draft]
    preferred_rehearsal_time { '〜20:00,22:30〜25:00' }
    preferred_performance_time { '19:00〜20:30,23:00〜' }
    notes { 'Vo がタンバリンを使うかもしれません。' }

    initialize_with { new attributes }
  end
end
