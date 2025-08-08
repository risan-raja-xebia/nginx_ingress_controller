# NGINX Ingress Controller - Separated Configuration Files

This directory contains the NGINX Ingress Controller configuration files separated by component type for better organization and maintainability.

## File Structure

- `namespace.yaml` - Namespace definition for ingress-nginx
- `serviceaccounts.yaml` - Service accounts for controller and admission webhook
- `rbac.yaml` - All RBAC resources (Roles, ClusterRoles, RoleBindings, ClusterRoleBindings)
- `configmap.yaml` - Configuration map for the controller
- `services.yaml` - LoadBalancer and ClusterIP services
- `deployment.yaml` - Main controller deployment
- `jobs.yaml` - Admission webhook certificate generation jobs
- `ingressclass.yaml` - IngressClass definition
- `webhook.yaml` - ValidatingWebhookConfiguration

## Deployment Order

Apply the files in the following order to ensure proper dependency resolution:

1. **Namespace** (required first)
   ```bash
   kubectl apply -f namespace.yaml
   ```

2. **RBAC** (required for service accounts and permissions)
   ```bash
   kubectl apply -f rbac.yaml
   ```

3. **Service Accounts** (required for pods)
   ```bash
   kubectl apply -f serviceaccounts.yaml
   ```

4. **ConfigMap** (configuration for controller)
   ```bash
   kubectl apply -f configmap.yaml
   ```

5. **Services** (LoadBalancer and admission webhook service)
   ```bash
   kubectl apply -f services.yaml
   ```

6. **Deployment** (main controller)
   ```bash
   kubectl apply -f deployment.yaml
   ```

7. **Jobs** (admission webhook certificate generation)
   ```bash
   kubectl apply -f jobs.yaml
   ```

8. **IngressClass** (defines the ingress class)
   ```bash
   kubectl apply -f ingressclass.yaml
   ```

9. **Webhook** (validating webhook configuration)
   ```bash
   kubectl apply -f webhook.yaml
   ```

## Alternative: Apply All at Once

You can also apply all files at once using:

```bash
kubectl apply -f .
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