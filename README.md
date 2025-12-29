# Shop Rails

Mind owning your own online store? This repository might be for you.

## Deployment

I recommend to use Docker-based tools as the deployment tool, like Kamal or Dokku. I personally recommend Dokku. If you were not familiar enough with Dokku, I wrote a free e-book in Bahasa Indonesia [here](https://shop.adipurnm.com/products/self-hosting-dengan-dokku).

Before deploying the application, ensure that these environment variables are all set.

```
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=
SECRET_KEY_BASE=
STORAGE_HOST=
APP_HOST=
```

Encryption is applied to the site settings values. To generate the encryption keys, run `rails db:encryption:init`.

To generate the `SECRET_KEY_BASE` value, run `rails secret`.

To set the environment variable in Dokku, run `dokku config:set app-name ENVVAR1=value1 ENVVAR2=value2`.

## First run

After the application is deployed, run this command within the Docker container to set-up the admin credentials and basic site configuration.

```bash
ruby scripts/setup_admin_user.rb
```

In Dokku, SSH to your server and run `dokku run app-name`, and execute the command above.

## Run it Locally

1. Clone this repository
2. Copy and the environment variables using `cp .env.example .env` command
3. Set the environment variables by following the instructions in the Deployment section
4. Run the development server: `bin/dev`

## Contributing

1. Fork this repository
2. Create a new branch for the enhancements/bug fixes/other related stuff
3. Submit a Pull Request to this repository

## License

[MIT License](https://opensource.org/license/mit).
