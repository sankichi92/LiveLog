class CloudinaryMigrationBatch < ApplicationBatch
  def run
    Member.with_attached_avatar.joins(avatar_attachment: :blob).left_joins(:new_avatar).where(avatars: { id: nil }).find_each do |member|
      member.avatar.open do |file|
        member.build_new_avatar.upload_and_save!(file)
      end
    end
  end
end
