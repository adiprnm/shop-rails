# Shop Rails

Mind owning your own online store? This repository might be for you.

## Deployment

I recommend to use Docker-based tools as the deployment tool, like Kamal or Dokku. I personally recommend Dokku. If you were not familiar enough with Dokku, I wrote a free e-book in Bahasa Indonesia [here](https://shop.adipurnm.com/products/self-hosting-dengan-dokku).

Before deploying the application, ensure that these environment variables are all set.

```
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=
STORAGE_HOST=
```

Encryption is applied to the site settings values. To generate the encryption keys, run `rails db:encryption:init`.

## First run

After the application is deployed, run this command within the Docker container to set-up the admin credentials and basic site configuration.

```bash
ruby scripts/setup_admin_user.rb
```

In Dokku, SSH to your server and run `dokku run app-name`, and execute the command above.


