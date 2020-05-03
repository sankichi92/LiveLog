class Avatar < ApplicationRecord
  belongs_to :member

  def upload_and_save!(file)
    response = Cloudinary::Uploader.upload(
      file,
      folder: 'avatar/',
      public_id: member.id,
    )
    update!(cloudinary_id: response['public_id'], metadata: response.except('public_id'))
  end

  def cloudinary_url(size)
    Cloudinary::Utils.cloudinary_url(
      cloudinary_id,
      sign_url: true,
      transformation: [
        {
          width: size,
          height: size,
          gravity: 'faces',
          crop: 'fill',
          quality: 'auto',
          fetch_format: 'auto',
        },
      ],
    )
  end
end
