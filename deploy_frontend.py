import subprocess
import json
import os
import random
import string
import shutil

# Configuration
REGION = "ap-south-1"
BUCKET_NAME = "hercare-app-frontend-cszaiz"
BUILD_DIR = "build/web"

def run_command(command, shell=True):
    try:
        subprocess.run(command, check=True, shell=shell)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e}")
        exit(1)

def main():
    print(f"🚀 Starting Frontend Deployment to AWS S3 ({REGION})...")
    print(f"📦 Bucket Name: {BUCKET_NAME}")

    # 1. Create Bucket
    print("\n1️⃣  Creating S3 Bucket...")
    try:
        run_command(f"aws s3api create-bucket --bucket {BUCKET_NAME} --region {REGION} --create-bucket-configuration LocationConstraint={REGION}")
    except:
        print("   (Bucket might already exist, continuing...)")

    # 2. Disable Block Public Access
    print("\n2️⃣  Unblocking Public Access...")
    run_command(f"aws s3api put-public-access-block --bucket {BUCKET_NAME} --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false")

    # 3. Set Bucket Policy (Public Read)
    print("\n3️⃣  Setting Public Read Policy...")
    policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": f"arn:aws:s3:::{BUCKET_NAME}/*"
            }
        ]
    }
    with open("s3_policy.json", "w") as f:
        json.dump(policy, f)
    
    run_command(f"aws s3api put-bucket-policy --bucket {BUCKET_NAME} --policy file://s3_policy.json")
    os.remove("s3_policy.json")

    # 4. Enable Website Hosting
    print("\n4️⃣  Enabling Static Website Hosting...")
    run_command(f"aws s3 website s3://{BUCKET_NAME}/ --index-document index.html --error-document index.html")

    # 5. Build Flutter Web
    print("\n5️⃣  Building Flutter Web App...")
    if os.path.exists(BUILD_DIR):
        shutil.rmtree(BUILD_DIR)
    run_command("flutter build web --release")

    # 6. Upload to S3
    print("\n6️⃣  Uploading to S3...")
    run_command(
        f"aws s3 sync {BUILD_DIR} s3://{BUCKET_NAME} --delete "
        f"--exclude '.git/*' --exclude '.git' --exclude '.last_build_id'"
    )

    # 7. Final URL
    print("\n✅ DEPLOYMENT COMPLETE!")
    print(f"🌍 Live URL: http://{BUCKET_NAME}.s3-website.{REGION}.amazonaws.com")

if __name__ == "__main__":
    main()
