# Quotas

A resource quota, defined by a ResourceQuota object, provides constraints that limit aggregate resource consumption per project. It can limit the quantity of objects that can be created in a project by type, as well as the total amount of compute resources and storage that may be consumed by resources in that project.

> Quotas are set by cluster administrators and are scoped to a given project.

# Limit Ranges

A limit range, defined by a LimitRange object, enumerates compute resource constraints in a project **at the pod, container, image, image stream, and persistent volume claim level**, and specifies the amount of resources that a pod, container, image, image stream, or persistent volume claim can consume.

All resource create and modification requests are evaluated against each LimitRange object in the project. If the resource violates any of the enumerated constraints, then the resource is rejected. If the resource does not set an explicit value, and if the constraint supports a default value, then the default value is applied to the resource.

> Limit ranges are set by cluster administrators and are scoped to a given project.

# Summary

**Quota vs Ranges**
