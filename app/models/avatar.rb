class Avatar < ApplicationRecord
  SIZE_TO_PIXEL = {
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
    Cloudinary::Utils.cloudinary_url(
      cloudinary_id,
      sign_url: true,
      transformation: [
        {
          width: SIZE_TO_PIXEL[size],
          aspect_ratio: 1,
          crop: 'fill',
          gravity: 'face:auto',
          quality: 'auto:good',
          fetch_format: 'auto',
        },
      ],
    )
  end
end
