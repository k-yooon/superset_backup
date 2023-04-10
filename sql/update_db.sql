-- update dbs encrypted_extra & create ssh_tunnels table

-- create public.ssh_tunnels table
CREATE TABLE public.ssh_tunnels (
	created_on timestamp NULL,
	changed_on timestamp NULL,
	created_by_fk int4 NULL,
	changed_by_fk int4 NULL,
	extra_json text NULL,
	uuid uuid NULL,
	id serial4 NOT NULL,
	database_id int4 NULL,
	server_address varchar(256) NULL,
	server_port int4 NULL,
	username bytea NULL,
	"password" bytea NULL,
	private_key bytea NULL,
	private_key_password bytea NULL,
	CONSTRAINT ssh_tunnels_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ix_ssh_tunnels_database_id ON public.ssh_tunnels USING btree (database_id);
CREATE UNIQUE INDEX ix_ssh_tunnels_uuid ON public.ssh_tunnels USING btree (uuid);

-- public.ssh_tunnels foreign keys
ALTER TABLE public.ssh_tunnels ADD CONSTRAINT ssh_tunnels_database_id_fkey FOREIGN KEY (database_id) REFERENCES public.dbs(id);

-- update dbs encrypted_extra
UPDATE public.dbs SET encrypted_extra = null WHERE id in (
  SELECT id FROM public.dbs
);
