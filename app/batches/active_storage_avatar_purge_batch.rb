class ActiveStorageAvatarPurgeBatch < ApplicationBatch
  def run
    Member.with_attached_old_avatar.joins(old_avatar_attachment: :blob).find_each do |member|
      member.old_avatar.purge
    end
  end
end
