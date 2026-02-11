#!/usr/bin/env bash
# crate_lookup.sh — Query crates.io API for Rust crate information
# Usage: crate_lookup.sh <command> [args...]
#
# Commands:
#   info    <crate>              — Crate metadata + latest version
#   search  <query>  [per_page]  — Search crates (default 10 results)
#   deps    <crate>  [version]   — Dependencies (default: latest)
#   versions <crate> [count]     — Recent versions (default 10)
#   rdeps   <crate>  [per_page]  — Reverse dependencies (default 10)
#   features <crate> [version]   — Feature flags (default: latest)

set -euo pipefail

API="https://crates.io/api/v1"
UA="User-Agent: claude-rust-docs-skill (https://github.com/apaxson)"

fetch() {
    curl -sf -H "$UA" "$1" 2>/dev/null
}

json_field() {
    # Lightweight jq alternative if jq isn't available
    if command -v jq &>/dev/null; then
        echo "$1" | jq -r "$2"
    else
        echo "[error] jq is required but not installed. Install with: apt-get install jq" >&2
        exit 1
    fi
}

cmd_info() {
    local crate="${1:?Usage: crate_lookup.sh info <crate_name>}"
    local data
    data=$(fetch "$API/crates/$crate") || { echo "Error: crate '$crate' not found"; exit 1; }

    echo "$data" | jq '{
        name: .crate.name,
        description: .crate.description,
        max_stable_version: .crate.max_stable_version,
        max_version: .crate.max_version,
        newest_version: .crate.newest_version,
        downloads: .crate.downloads,
        recent_downloads: .crate.recent_downloads,
        repository: .crate.repository,
        documentation: .crate.documentation,
        homepage: .crate.homepage,
        license: (.versions[0].license // "unknown"),
        rust_version: (.versions[0].rust_version // "unknown"),
        keywords: .crate.keywords,
        categories: .crate.categories,
        created_at: .crate.created_at,
        updated_at: .crate.updated_at,
        latest_features: (.versions[0].features // {}),
        docs_rs: ("https://docs.rs/" + .crate.name + "/" + (.crate.max_stable_version // .crate.max_version)),
        cargo_add: ("cargo add " + .crate.name)
    }'
}

cmd_search() {
    local query="${1:?Usage: crate_lookup.sh search <query> [per_page]}"
    local per_page="${2:-10}"
    local encoded_query
    encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))" 2>/dev/null || echo "$query")

    local data
    data=$(fetch "$API/crates?q=$encoded_query&per_page=$per_page") || { echo "Error: search failed"; exit 1; }

    echo "$data" | jq '{
        total: .meta.total,
        crates: [.crates[] | {
            name: .name,
            description: .description,
            max_stable_version: .max_stable_version,
            downloads: .downloads,
            recent_downloads: .recent_downloads,
            updated_at: .updated_at,
            repository: .repository,
            docs_rs: ("https://docs.rs/" + .name)
        }]
    }'
}

cmd_deps() {
    local crate="${1:?Usage: crate_lookup.sh deps <crate> [version]}"
    local version="${2:-}"

    # If no version specified, get the latest
    if [[ -z "$version" ]]; then
        version=$(fetch "$API/crates/$crate" | jq -r '.crate.max_stable_version // .crate.max_version') \
            || { echo "Error: crate '$crate' not found"; exit 1; }
    fi

    local data
    data=$(fetch "$API/crates/$crate/$version/dependencies") || { echo "Error: version '$version' not found for '$crate'"; exit 1; }

    echo "$data" | jq --arg crate "$crate" --arg version "$version" '{
        crate: $crate,
        version: $version,
        dependencies: [.dependencies[] | {
            name: .crate_id,
            version_req: .req,
            kind: .kind,
            optional: .optional,
            default_features: .default_features,
            features: .features
        }] | sort_by(.kind, .name)
    }'
}

cmd_versions() {
    local crate="${1:?Usage: crate_lookup.sh versions <crate> [count]}"
    local count="${2:-10}"

    local data
    data=$(fetch "$API/crates/$crate") || { echo "Error: crate '$crate' not found"; exit 1; }

    echo "$data" | jq --argjson count "$count" '{
        crate: .crate.name,
        total_versions: (.versions | length),
        recent: [.versions[:$count][] | {
            version: .num,
            published: .created_at,
            yanked: .yanked,
            rust_version: .rust_version,
            license: .license,
            size_kb: ((.crate_size // 0) / 1024 | floor)
        }]
    }'
}

cmd_rdeps() {
    local crate="${1:?Usage: crate_lookup.sh rdeps <crate> [per_page]}"
    local per_page="${2:-10}"

    local data
    data=$(fetch "$API/crates/$crate/reverse_dependencies?per_page=$per_page") \
        || { echo "Error: crate '$crate' not found"; exit 1; }

    echo "$data" | jq '{
        total: .meta.total,
        reverse_dependencies: [.versions[] | {
            crate: .crate_id,
            version: .num,
            downloads: .downloads
        }] | sort_by(-.downloads)
    }'
}

cmd_features() {
    local crate="${1:?Usage: crate_lookup.sh features <crate> [version]}"
    local version="${2:-}"

    local data
    data=$(fetch "$API/crates/$crate") || { echo "Error: crate '$crate' not found"; exit 1; }

    if [[ -z "$version" ]]; then
        # Get features from the latest version
        echo "$data" | jq '{
            crate: .crate.name,
            version: .versions[0].num,
            features: .versions[0].features,
            default_features: (.versions[0].features.default // [])
        }'
    else
        # Find the specific version
        echo "$data" | jq --arg v "$version" '
            (.versions[] | select(.num == $v)) as $ver |
            if $ver then {
                crate: .crate.name,
                version: $ver.num,
                features: $ver.features,
                default_features: ($ver.features.default // [])
            } else
                error("version \($v) not found")
            end
        '
    fi
}

# Main dispatch
case "${1:-help}" in
    info)     shift; cmd_info "$@" ;;
    search)   shift; cmd_search "$@" ;;
    deps)     shift; cmd_deps "$@" ;;
    versions) shift; cmd_versions "$@" ;;
    rdeps)    shift; cmd_rdeps "$@" ;;
    features) shift; cmd_features "$@" ;;
    help|--help|-h)
        echo "Usage: crate_lookup.sh <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  info     <crate>             Crate metadata + latest version"
        echo "  search   <query> [per_page]  Search crates (default 10)"
        echo "  deps     <crate> [version]   Dependencies (latest if omitted)"
        echo "  versions <crate> [count]     Recent versions (default 10)"
        echo "  rdeps    <crate> [per_page]  Reverse dependencies (default 10)"
        echo "  features <crate> [version]   Feature flags (latest if omitted)"
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "Run with --help for usage" >&2
        exit 1
        ;;
esac
