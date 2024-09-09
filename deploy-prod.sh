#!/bin/bash
rsync -avz -e ssh ../twin_commons/assets/* lb:/data/nginx/static/apps/nocode/assets/
rsync -avz -e ssh ../twinned_widgets/assets/* lb:/data/nginx/static/apps/nocode/assets/
rsync -avz -e ssh build/web/* lb:/data/nginx/static/apps/nocode/
rsync -avz -e ssh build/web/assets/assets/* lb:/data/nginx/static/apps/nocode/assets/
