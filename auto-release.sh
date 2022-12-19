PRERELASE=0
AUTODESCRIPTION=0

function print_usage() {
  echo "auto release on github. Script gets last version and increments it. After it creates new release"
  echo "  -r  github release url"
  echo "    e.g. https://api.github.com/repos/{USER}/{REPO}/releases"
  echo "  -t  github token"
  echo "  -p  set as prerelease"
  echo "  -a  autogenerate description for release"
}

while getopts 'r:t:pa' flag; do
  case "${flag}" in
    r) RELESASE_URL="${OPTARG}" ;;
    t) TOKEN="${OPTARG}" ;;
    p) PRERELASE=1 ;;
    a) AUTODESCRIPTION=1 ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [[ $PRERELASE == 1 ]]; then
  PRERELASE="true"
else
  PRERELASE="false"
fi

if [[ $AUTODESCRIPTION == 1 ]]; then
  AUTODESCRIPTION="true"
else
  AUTODESCRIPTION="false"
fi


function addVersion()
{
  version=$1
  vers=$(echo $version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(100^length($NF))); print}')
  echo $vers

  # return $vers
}
function fetchGithubReleases(){
  res=$(curl --no-progress-meter \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
    "$RELESASE_URL")
  echo $res
}

function createNewRelease(){
  vers=$1
  p='"'
  # x='"tag_name":$vers,"target_commitish":"master","name":$vers,"body":"Release generated by github-auto-release bot by randomguy090","draft":false,"prerelease":${PRERELASE},"generate_release_notes":false'
  x="${p}tag_name${p}:${p}$vers${p},${p}target_commitish${p}:${p}master${p},${p}name${p}:${p}$vers${p},${p}body${p}:${p}# Release $vers ### Release generated by github-auto-release bot by randomguy090${p},${p}draft${p}:false,${p}prerelease${p}:${PRERELASE},${p}generate_release_notes${p}:${AUTODESCRIPTION}"
  
  x=${x//'"'/'X'}
  vers="X${vers}X"

  x=${x//'$vers'/"$vers"}
  x=${x//'X'/'"'}
  params="{$x}"
  echo "'${params}'"
  p='"'
  xD=$(echo -H '"Accept: application/vnd.github+json"' -H \
    "${p}Authorization: Bearer ${TOKEN}$p"  \
     -H '"X-GitHub-Api-Version: 2022-11-28"'\
      "${p}${RELESASE_URL}${p}" \
       -d "'${params}'" )

  x=$(eval "curl --no-progress-meter $xD")
  vers=${vers//'X'/''}
  echo $x
  echo $vers
}

res=$(fetchGithubReleases)

IFS="}, {"
parsed=$(readarray -td, a <<<$res; declare -p a;)
read -a strarr <<< "$parsed"


if [[ $res != "[ ]" ]]; then
  
  for index in "${!strarr[@]}"
  do
      if [[ ${strarr[index]} == *'"name"'* ]]; then

            x=$(( $index + 1 ))

            version=${strarr[x]}

            x=$(( ${#version} - 2 ))

            if [[ $version == *"v"* ]]; then
              version=$(echo $version | cut -c  3-$x)
            else
              x=$(( ${#version} - 1 ))
              version=$(echo $version | cut -c  1-$x)

            fi

            version="v${version}"

            break
      fi

  done

else
  version="v1.0.0"
fi


newVer=$(addVersion $version )

createNewRelease $newVer

exit 0

