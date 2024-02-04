function attachable_geom(
  size, size2, shift,
  r,r1,r2, d,d1,d2, l,h,
  vnf, path, region,
  extent=true,
  cp=[0,0,0],
  offset=[0,0,0],
  anchors=[],
  two_d=false,
  axis=UP,override,
  geom
) =
//  assert($children==2, "attachable() expects exactly two children; the shape to manage, and the union of all attachment candidates.")
//  assert(is_undef(anchor) || is_vector(anchor) || is_string(anchor), str("Got: ",anchor))
//  assert(is_undef(spin)   || is_vector(spin,3) || is_num(spin), str("Got: ",spin))
//  assert(is_undef(orient) || is_vector(orient,3), str("Got: ",orient))
  let (
    region = !is_undef(region)? region :
      !is_undef(path)? [path] :
      undef
  )
  is_def(geom)? geom :
      attach_geom(
          size=size, size2=size2, shift=shift,
          r=r, r1=r1, r2=r2, h=h,
          d=d, d1=d1, d2=d2, l=l,
          vnf=vnf, region=region, extent=extent,
          cp=cp, offset=offset, anchors=anchors,
          two_d=two_d, axis=axis, override=override
      );

