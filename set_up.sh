export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")@cloudbuild.gserviceaccount.com \
    --role="roles/clouddeploy.operator"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")@cloudbuild.gserviceaccount.com \
    --role="roles/iam.serviceAccountUser"

gcloud container clusters create-auto staging \
    --region ${REGION} \
    --project=${PROJECT_ID} \
    --async

gcloud container clusters create-auto prod \
    --region ${REGION} \
    --project=${PROJECT_ID} \
    --async

gcloud container clusters list

gcloud container clusters get-credentials staging --region ${REGION}
gcloud container clusters get-credentials prod --region ${REGION}

sed -i .old1 "s/project-id-placeholder/${PROJECT_ID}/g;s/region-placeholder/${REGION}/g" deploy/*.yaml



gcloud artifacts repositories create cicd-sample-repo \
    --repository-format=Docker \
    --location ${REGION}

gsutil mb gs://${PROJECT_ID}-gceme-artifacts/

gcloud beta builds triggers create github \
    --name=cicd-demo \
    --repo-name="golden-path-for-app-delivery" \
    --repo-owner="evillgenius75" \
    --branch-pattern="main" \
    --build-config="cloudbuild.yaml"

