# NGINX Ingress Controller - Separated Configuration Files

This directory contains the NGINX Ingress Controller configuration files separated by component type and numbered in the order they should be executed for proper dependency resolution.

## File Structure (in execution order)

- `01-namespace.yaml` - Namespace definition for ingress-nginx
- `02-rbac.yaml` - All RBAC resources (Roles, ClusterRoles, RoleBindings, ClusterRoleBindings)
- `03-serviceaccounts.yaml` - Service accounts for controller and admission webhook
- `04-configmap.yaml` - Configuration map for the controller
- `05-services.yaml` - LoadBalancer and ClusterIP services
- `06-deployment.yaml` - Main controller deployment
- `07-jobs.yaml` - Admission webhook certificate generation jobs
- `08-ingressclass.yaml` - IngressClass definition
- `09-webhook.yaml` - ValidatingWebhookConfiguration

  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-scheme: internal
    service.beta.kubernetes.io/aws-load-balancer-name: nginx-load-balancer
    service.beta.kubernetes.io/aws-load-balancer-subnets: subnet-0a1123eb7a53067b8, subnet-005d4443220a8175a
    service.beta.kubernetes.io/aws-load-balancer-private-ipv4-addresses: 10.0.2.156, 10.0.1.210

## Deployment Order

Apply the files in numerical order to ensure proper dependency resolution:

1. **Namespace** (required first)
   ```bash
   kubectl apply -f nginx/01-namespace.yaml
   ```

2. **RBAC** (required for service accounts and permissions)
   ```bash
   kubectl apply -f nginx/02-rbac.yaml
   ```

3. **Service Accounts** (required for pods)
   ```bash
   kubectl apply -f nginx/03-serviceaccounts.yaml
   ```

4. **ConfigMap** (configuration for controller)
   ```bash
   kubectl apply -f nginx/04-configmap.yaml
   ```

5. **Services** (LoadBalancer and admission webhook service)
   ```bash
   kubectl apply -f nginx/05-services.yaml
   ```

6. **Deployment** (main controller)
   ```bash
   kubectl apply -f nginx/06-deployment.yaml
   ```

7. **Jobs** (admission webhook certificate generation)
   ```bash
   kubectl apply -f nginx/07-jobs.yaml
   ```

8. **IngressClass** (defines the ingress class)
   ```bash
   kubectl apply -f nginx/08-ingressclass.yaml
   ```

9. **Webhook** (validating webhook configuration)
   ```bash
   kubectl apply -f nginx/09-webhook.yaml
   ```

## Alternative: Apply All at Once

You can also apply all files at once using:

```bash
kubectl apply -f nginx/
```

## Verification

After deployment, verify the installation:

```bash
# Check if all pods are running
kubectl get pods -n ingress-nginx

# Check services
kubectl get svc -n ingress-nginx

# Check if the controller is working
kubectl get ingressclass nginx
```

## Notes

- The LoadBalancer service is configured for AWS with internal scheme and specific subnets
- SSL redirect is enabled by default
- The controller uses version 1.12.3 of the NGINX Ingress Controller
- All resources are labeled consistently for easy management
- Files are numbered in the order they should be executed for proper dependency resolution 