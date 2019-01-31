CREATE TABLE IF NOT EXISTS commits (
    hash VARCHAR(42) PRIMARY KEY,
    author_name VARCHAR NOT NULL,
    author_email VARCHAR NOT NULL,
    author_timestamp INTEGER NOT NULL,
    committer_name VARCHAR NOT NULL,
    committer_email VARCHAR NOT NULL,
    committer_timestamp INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS files (
    hash VARCHAR(42) NOT NULL,
    added_lines INTEGER NOT NULL,
    deleted_lines INTEGER NOT NULL,
    file VARCHAR NOT NULL,
    FOREIGN KEY(hash) REFERENCES commits(hash)
);

CREATE TABLE IF NOT EXISTS messages (
    hash VARCHAR(42) NOT NULL,
    topic VARCHAR NOT NULL,
    message TEXT NOT NULL,
    FOREIGN KEY(hash) REFERENCES commits(hash)
);

CREATE TABLE IF NOT EXISTS parents (
    child VARCHAR(42) NOT NULL,
    parent VARCHAR(42) NOT NULL,
    FOREIGN KEY(child) REFERENCES commits(hash),
    FOREIGN KEY(parent) REFERENCES commits(hash)
);

CREATE TABLE IF NOT EXISTS repositories (
    id INTEGER PRIMARY KEY,
    user VARCHAR NOT NULL,
    project VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS commits_repositories (
    hash VARCHAR(42) NOT NULL,
    repository INTEGER NOT NULL,
    FOREIGN KEY(repository) REFERENCES repositories(id),
    FOREIGN KEY(hash) REFERENCES commits(hash)
);
