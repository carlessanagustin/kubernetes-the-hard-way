* taint: Allow a node to repel a set of pods.
    * A taint consists of a key, value, and effect. As an argument here, it is expressed as key=value:effect.
    * effect = NoSchedule | PreferNoSchedule | NoExecute

* drain: Drain node in preparation for maintenance.
    * The given node will be marked unschedulable to prevent new pods from arriving.
    * It will use normal DELETE to delete the pods.

* cordon: Mark node as unschedulable
