#!/bin/bash
rsync -avz -e ssh ../twin_commons/assets/* lbdev:/data/nginx/static/apps/nocode/assets/
rsync -avz -e ssh ../twinned_widgets/assets/* lbdev:/data/nginx/static/apps/nocode/assets/
rsync -avz -e ssh build/web/* lbdev:/data/nginx/static/apps/nocode/
rsync -avz -e ssh build/web/assets/assets/* lbdev:/data/nginx/static/apps/nocode/assets/
