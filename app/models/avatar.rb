class Avatar < ApplicationRecord
  IMAGE_PX_BY_SIZE = {
    small:  16 *  2 * 2,
    medium: 16 *  6 * 2,
    large:  16 * 12 * 2,
  }.freeze

  belongs_to :member, touch: true

  def upload_and_save!(file)
    response = Cloudinary::Uploader.upload(
      file,
      folder: 'avatar/',
      public_id: member.id,
      allowed_formats: %w[jpg png],
    )
    update!(cloudinary_id: response['public_id'], metadata: response.except('public_id'))
  end

  def image_url(size: :small)
    px = IMAGE_PX_BY_SIZE[size]
    Cloudinary::Utils.cloudinary_url(
      cloudinary_id,
      sign_url: true,
      transformation: [
        {
          width: px,
          height: px,
          gravity: 'faces',
          crop: 'fill',
          quality: 'auto',
          fetch_format: 'auto',
        },
      ],
    )
  end
end
