# List-It (revival)

List-It is a community for making and sharing top-10 lists, built at the Le Wagon coding bootcamp in 2022.
This is a revived copy of the original class project, updated to run today:

- **Ruby 3.3 and Rails 8.1** (was Ruby 3.0 / Rails 6.1 with Webpacker)
- JavaScript bundled with **esbuild**, styles compiled with **Dart Sass** (jsbundling-rails / cssbundling-rails, Propshaft)
- **Invite-only logins**: public sign-up is switched off. Admins create logins for friends at `/admin/users`.
- **Try the demo**: visitors can explore with one click as the shared `@demo` account, which resets itself regularly.
- Users can only change their own lists and items (admins can change anything), and drafts are private.
- Images use Active Storage on local disk by default, or Cloudinary when `CLOUDINARY_URL` is set.

## Running it with Docker (production)

```sh
cp .env.example .env      # fill in SECRET_KEY_BASE, POSTGRES_PASSWORD, ADMIN_EMAIL, ADMIN_PASSWORD, DOMAIN
docker compose up -d --build
```

That starts three containers:

| Service      | What it does |
|--------------|--------------|
| `web`        | The Rails app on port `APP_PORT` (3000 by default). Put your reverse proxy (Caddy, nginx, Traefik…) in front of it for HTTPS. |
| `db`         | Postgres 16, data kept in the `db-data` volume. |
| `demo-reset` | Puts the demo account back to its starter content every `DEMO_RESET_HOURS` hours. |

On first boot the database is created and seeded automatically: the sample community from the original project,
your admin login (from `ADMIN_EMAIL` / `ADMIN_PASSWORD`), and the demo account. Uploaded images are kept in the `uploads` volume.

If you are not serving over HTTPS yet, set `ASSUME_SSL=false` and `FORCE_SSL=false` in `.env`.

### Useful commands

```sh
docker compose exec web bin/rails demo:reset                                    # reset the demo now
docker compose exec web bin/rails admin:create EMAIL=me@example.com PASSWORD=…  # create or fix an admin login
docker compose exec web bin/rails console
```

## Managing logins

Log in as an admin, open your profile and press **Admin**. From there you can:

- **New login**: pick a username and email. A random password is filled in. After saving, the page shows the details once so you can send them to your friend.
- **Edit**: change someone's email or username, set a new password, or make them an admin.
- **Delete** a login and everything they made.

Everyone can change their own username, email, bio, avatar and password from **Account** on their profile (except the demo account).

## Development

Requirements: Ruby 3.3, Node 22 with Yarn 1, and Postgres.

```sh
bin/setup                 # installs gems and packages, prepares the database, starts the app
bin/dev                   # later: runs Rails plus the JS and CSS watchers on http://localhost:3000
bin/rails test
```

In development the seeds create an admin `admin@example.com` / `password123`.
`SEED_RESET=1 bin/rails db:seed` wipes the database and seeds it again.

---

Originally built by the List-It team at Le Wagon (batch of 2022). Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates).
